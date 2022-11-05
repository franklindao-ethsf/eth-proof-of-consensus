import { ethers } from "ethers";
// import dotenv from "dotenv";
// dotenv.config();

const provider = new ethers.providers.JsonRpcProvider(
    "https://rpc.ankr.com/eth_goerli",
);
console.log(process.env.GOERLI_PRIVATE_KEY);

const wallet = new ethers.Wallet(process.env.GOERLI_PRIVATE_KEY, provider);
const deposit_addr = "0x8EDeAdEd3D9b45F30e725fe069bD9FFDb9571bDD";
const caller_pubkey = "0x7C7E6c69830F182A70be37eE9778724df930b5b3";
const gsb_addr = "0x45cD94330AC3aeA42cc21Cf9315B745e27e768BD";

console.log(wallet.address);

// Instantiate Contract
// deposittoken = pkey
const deposit_contractABI = ["function deposit(address recipient, uint256 amount, address tokenAddress)"];
const gsb_contractABI = ["function approve(address spender,uint256 amount)"]
const faucet_contractABI = ["function mint(address to, uint256 amount)"]


const faucet_addr = "0x45cD94330AC3aeA42cc21Cf9315B745e27e768BD"
const faucet_contract = new ethers.Contract(faucet_addr, faucet_contractABI, wallet);
faucet_contract.connect(wallet);

const deposit_contract = new ethers.Contract(deposit_addr, deposit_contractABI, wallet);
deposit_contract.connect(wallet);

const approve_contract = new ethers.Contract(gsb_addr, gsb_contractABI, wallet);
approve_contract.connect(wallet);

async function main() {
    const faucet_tx = await faucet_contract.mint(
        caller_pubkey,
        69420,
        {
            gasLimit: 50000,
        }
    )
    console.log(faucet_tx);
    console.log(faucet_tx.wait());
    console.log("faucet done");

    const approve_tx = await approve_contract.approve(
        deposit_addr,
        69
    )
    console.log(approve_tx);
    console.log(await approve_tx.wait())
    console.log("approve done");

    const tx = await deposit_contract.deposit(
        caller_pubkey,
        1,
        gsb_addr,
        // inputs
        {
            value: 0,
            gasLimit: 100000,
        }
    )
    console.log(tx);
    console.log(await tx.wait())
    console.log("deposit done");
}

main().catch((err) => {
    console.error(err)
    process.exit(1)
})
