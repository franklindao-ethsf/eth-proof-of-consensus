import { ethers, Wallet } from "ethers"; 
import axios from "axios"; 
// import ABI
import TokenBridgeABI from "../artifacts/contracts/WormholeTokenBridge/TokenBridge.sol/TokenBridge.json" assert {type: 'json'}

// Provider and Signer
const mnemonic = ""; 
const walletMnemonic = Wallet.fromMnemonic(mnemonic); 
const provider = new ethers.providers.JsonRpcProvider('');
const signer = walletMnemonic.connect(provider);

// Instantiate Contract
const contractAddress = ""; 
const contractABI = ""; 

const contract = new ethers.Contract(contractAddress, contractABI, signer);
contract.connect(signer); 

console.log(recipient)

async function main() {
    const tx = await contract.transferTokens(
        // inputs 
        nonce,
        {
            value: amount,
            gasLimit: 1000000,
        }
    )
    console.log(tx); 
    console.log(await tx.wait())
}

main().catch((err) => {
    console.error(err)
    process.exit(1)
})