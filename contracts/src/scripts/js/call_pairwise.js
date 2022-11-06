import {ethers} from "ethers";
// import dotenv from "dotenv";
// dotenv.config();

const goerliProvider = new ethers.providers.JsonRpcProvider(
    process.env.GOERLI_RPC_URL,
);
console.log(process.env.GOERLI_PRIVATE_KEY);

const goerliWallet = new ethers.Wallet(process.env.GOERLI_PRIVATE_KEY, goerliProvider);
const deposit_addr = "0xB9B112e2c591DeaDe330f1c2C28eC7EfaC84f1A7";
const caller_pubkey = process.env.GOERLI_PUBLIC_KEY;
const gsb_addr = "0x80ed42C3601CD1E05c062cF0c6Edc037D1658C92";
const gnosis_addr = "0x22932A69b4e078963c44c3B6f31A7677C72ED0dE";
const withdraw_addr = "0xA7c4EE85071949A00B4f65FdEDca41f79ba0DDc9";

console.log(goerliWallet.address);

const gnosisProvider = new ethers.providers.JsonRpcProvider(
    process.env.GNOSIS_RPC_URL,
);
console.log(process.env.GNOSIS_PRIVATE_KEY);

const gnosisWallet = new ethers.Wallet(process.env.GNOSIS_PRIVATE_KEY, gnosisProvider);

// Instantiate Contract
// deposittoken = pkey
const deposit_contractABI = ["function deposit(uint8 tokenId, address recipient,uint256 amount,address tokenAddress,uint16 destinationChainId)", "function addToken(uint8 tokenId, uint16 sourceChain, uint16[] calldata chainIds, address[] calldata addresses)"];
const gsb_contractABI = ["function approve(address spender,uint256 amount)"]
const faucet_contractABI = ["function mint(address to, uint256 amount)"]
const withdraw_contractABI = ["function receiveSuccinct(address srcAddress,bytes calldata callData)", "function addToken(uint8 tokenId, uint16 sourceChain, uint16[] calldata chainIds, address[] calldata addresses)"];
const mint_contractABI = ["function mint(address to, uint256 amount)"]

const faucet_contract = new ethers.Contract(gsb_addr, faucet_contractABI, goerliWallet);
faucet_contract.connect(goerliWallet);

const deposit_contract = new ethers.Contract(deposit_addr, deposit_contractABI, goerliWallet);
deposit_contract.connect(goerliWallet);

const approve_contract = new ethers.Contract(gsb_addr, gsb_contractABI, goerliWallet);
approve_contract.connect(goerliWallet);

const withdraw_contract = new ethers.Contract(withdraw_addr, withdraw_contractABI, gnosisWallet);
withdraw_contract.connect(gnosisWallet);

const mint_contract = new ethers.Contract(gnosis_addr, mint_contractABI, gnosisWallet);
mint_contract.connect(gnosisWallet);

async function main() {
    // const mint_tx = await mint_contract.mint(gnosisWallet.address, 69420, {gasLimit: 1000000});
    // console.log("mint_tx")
    // console.log(mint_tx);
    // const mint_receipt = await mint_tx.wait();
    // console.log(mint_receipt);
    // // //
    // const add_token_deposit_tx = await deposit_contract.addToken(1, 5, [5, 100], [gsb_addr, gnosis_addr], {gasLimit: 1000000});
    // console.log("add_token_deposit_tx")
    // console.log(add_token_deposit_tx);
    // const add_token_deposit_receipt = await add_token_deposit_tx.wait();
    // console.log(add_token_deposit_receipt);
    //
    // const add_token_withdraw_tx = await withdraw_contract.addToken(1, 5, [5, 100], [gsb_addr, gnosis_addr], {gasLimit: 1000000});
    // console.log("add_token_withdraw_tx")
    // console.log(add_token_withdraw_tx);
    // const add_token_withdraw_receipt = await add_token_withdraw_tx.wait();
    // console.log(add_token_withdraw_receipt);

    const faucet_tx = await faucet_contract.mint(
        caller_pubkey,
        69420,
        {
            gasLimit: 500000,
        }
    )
    console.log("faucet_tx")
    console.log(faucet_tx);
    const faucet_receipt = await faucet_tx.wait();
    console.log(faucet_receipt);

    const approve_tx = await approve_contract.approve(
        deposit_addr,
        69420
    )
    console.log("approve_tx")
    console.log(approve_tx);
    const approve_receipt = await approve_tx.wait();
    console.log(approve_receipt);

    const tx = await deposit_contract.deposit(
        1,
        caller_pubkey,
        1,
        gsb_addr,
        100,
        // inputs
        {
            gasLimit: 1000000,
        }
    )
    console.log("deposit_tx")
    console.log(tx);
    const receipt = await tx.wait();
    console.log(receipt);

    const tx2 = await deposit_contract.deposit(
        1,
        caller_pubkey,
        1,
        gsb_addr,
        420,
        // inputs
        {
            gasLimit: 1000000,
        }
    )
    console.log("deposit_tx")
    console.log(tx2);
    const receipt2 = await tx2.wait();
    console.log(receipt2);

    // const withdraw_tx = await withdraw_contract.receiveSuccinct(
    //     caller_pubkey,
    //     1,
    //     {
    //         gasLimit: 200000,
    //     }
    // )
    // console.log(withdraw_tx);
    // console.log(await withdraw_tx.wait())
    // console.log("withdraw done");
}

main().catch((err) => {
    console.error(err)
    process.exit(1)
})
