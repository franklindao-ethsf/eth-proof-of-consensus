// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "forge-std/console.sol";
import "../amb/interfaces/ITrustlessAMB.sol";
import "./Tokens.sol";

contract PairwiseBridge is Ownable {
    struct TokenInfo {
        uint16 sourceChainId;
        // chain to tokens
        mapping (uint16 => address) tokenAddresses;
    }

    mapping (uint8 => TokenInfo) public tokenRegistry;

    function addToken(uint8 tokenId, uint16 sourceChain, uint16[] calldata chainIds, address[] calldata addresses) public onlyOwner {
        require(chainIds.length == addresses.length, "Length of two arrays must be the same");

        for (uint i=0; i < chainIds.length; i++) {
            tokenRegistry[tokenId].sourceChainId = sourceChain;
            tokenRegistry[tokenId].tokenAddresses[chainIds[i]] = addresses[i];
        }
    }

	mapping(address => address) public tokenAddressConverter;

	function setMapping(address addr1, address addr2) public onlyOwner {
		tokenAddressConverter[addr1] = addr2;
	}
}

contract Deposit is PairwiseBridge {
    ITrustlessAMB homeAmb;
    mapping (uint16 => address) foreignAddresses;
	uint16 chainId;
    // GAS_LIMIT is how much gas the foreignWithdraw contract will
    // have to execute the withdraw function. Foundry estimates 33536
    // so we leave some buffer.
    uint256 internal constant GAS_LIMIT = 50000;

	event DepositEvent(
        uint8 indexed tokenId,
		address indexed from,
		address indexed recipient,
		uint256 amount,
		address tokenAddress,
        uint16 destinationChainId,
        address destinationToken
	);

    event TestEvent(
        uint8 num
    );

	constructor(ITrustlessAMB _homeAmb, uint16 _chainId) {
        homeAmb = _homeAmb;
		chainId = _chainId;
	}

	function deposit(
        uint8 tokenId,
		address recipient,
		uint256 amount,
		address tokenAddress,
        uint16 destinationChainId // new destination chainId address
	) external virtual {
		require(tokenAddressConverter[tokenAddress] != address(0), "Invalid token address");
        require(foreignAddresses[destinationChainId] != address(0), "Invalid destination chainId");
        require(amount <= 100, "Can deposit a max of 100 tokens at a time");
		require(IERC20(tokenAddress).balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(tokenRegistry[tokenId].sourceChainId != 0, "Invalid sourceChainId");

        // if mapping exists => native => lock
        if (tokenRegistry[tokenId].sourceChainId != chainId) {
            IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        } else {
            // if non native token => burn
            IERC20(tokenAddress).transferFrom(msg.sender, address(0), amount);
        }

        emit TestEvent(tokenId);

        require(tokenRegistry[tokenId].tokenAddresses[destinationChainId] != address(0), "Invalid destination token address");
        address destinationToken = tokenRegistry[tokenId].tokenAddresses[destinationChainId];


        bytes memory msgData = abi.encode(tokenId, recipient, amount, tokenAddress, destinationChainId, destinationToken);
        homeAmb.send(foreignAddresses[destinationChainId], destinationChainId, GAS_LIMIT, msgData);
		emit DepositEvent(tokenId, msg.sender, recipient, amount, tokenAddress, destinationChainId, destinationToken);
	}

    function setFA(uint16 id, address addr) public onlyOwner {
        foreignAddresses[id] = addr;
    }
}

// contract DepositMock is Deposit {
// 	constructor(ITrustlessAMB _homeAmb, address _foreignWithdraw, uint16 _chainId) Deposit(_homeAmb, _foreignWithdraw, _chainId) {
// 	}

// 	// We have a mock for testing purposes.
// 	function deposit(
// 		address recipient,
// 		uint256 amount,
// 		address tokenAddress
// 	) external override {
// 		require(tokenAddressConverter[tokenAddress] != address(0), "Invalid token address");
//         require(amount <= 100, "Can deposit a max of 100 tokens at a time");
// 		// Do not do any of the checks involving ERC20.
// 		bytes memory msgData = abi.encode(recipient, amount, tokenAddress);
//         homeAmb.send(foreignWithdraw, chainId, GAS_LIMIT, msgData);
// 		emit DepositEvent(msg.sender, recipient, amount, tokenAddress);
// 	}
// }

contract Withdraw is PairwiseBridge {
    address foreignAmb;
    IERC20Ownable public token;

    address sameChainDeposit;

	event WithdrawEvent(
		address indexed from,
		address indexed recipient,
		uint256 amount,
		address tokenAddress,
		address newTokenAddress
	);

	constructor(address _foreignAmb, address _sameChainDeposit) {
		foreignAmb = _foreignAmb;
        sameChainDeposit = _sameChainDeposit;
        token = new SuccinctToken();
        uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        // Mint the max number of tokens to this contract
        token.mint(address(this), MAX_INT);
	}

	function receiveSuccinct(
        address srcAddress,
        bytes calldata callData
	) public {
        require(msg.sender == foreignAmb, "Only foreign amb can call this function");

        (uint8 tokenId, address recipient, uint256 amount, address tokenAddress, uint16 destinationChainId, address destinationToken) = abi.decode(callData, (uint8, address, uint256, address, uint16, address));

        address newTokenAddress = tokenAddressConverter[tokenAddress];
        require(newTokenAddress != address(0), "Invalid token address");

        if (destinationChainId == tokenRegistry[tokenId].sourceChainId) {
            // unlock or transfer out of the deposit contract on this chain
            IERC20(destinationToken).transferFrom(sameChainDeposit, recipient, amount);
        } else {
            // mint new
            IERC20(destinationToken).transfer(recipient, amount);
        }
		emit WithdrawEvent(msg.sender, recipient, amount, tokenAddress, newTokenAddress);
	}
}
