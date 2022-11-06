import { ethers } from "ethers";
// import dotenv from "dotenv";
// dotenv.config();

const goerliProvider = new ethers.providers.JsonRpcProvider(
    process.env.GOERLI_RPC_URL,
);
console.log(process.env.GOERLI_PRIVATE_KEY);

const goerliWallet = new ethers.Wallet(process.env.GOERLI_PRIVATE_KEY, goerliProvider);
const deposit_addr = "0x732a1fDDC9C52e838C06C9DFec5802104f31fB32";
const caller_pubkey = process.env.GOERLI_PUBLIC_KEY;
const gsb_addr = "0x45cD94330AC3aeA42cc21Cf9315B745e27e768BD";
const withdraw_addr = "0x9D56678C4A4d92A2Edf75b02AD88dbB8deA9d850";

console.log(goerliWallet.address);

const gnosisProvider = new ethers.providers.JsonRpcProvider(
    process.env.GNOSIS_RPC_URL,
);
console.log(process.env.GNOSIS_PRIVATE_KEY);

const gnosisWallet = new ethers.Wallet(process.env.GNOSIS_PRIVATE_KEY, gnosisProvider);

// Instantiate Contract
// deposittoken = pkey
const deposit_contractABI = ["function deposit(address recipient, uint256 amount, address tokenAddress)"];
const gsb_contractABI = ["function approve(address spender,uint256 amount)"]
const faucet_contractABI = ["function mint(address to, uint256 amount)"]
const withdraw_contractABI = ["function receiveSuccinct(address srcAddress,bytes calldata callData)"];

const faucet_addr = "0x45cD94330AC3aeA42cc21Cf9315B745e27e768BD"
const faucet_contract = new ethers.Contract(faucet_addr, faucet_contractABI, goerliWallet);
faucet_contract.connect(goerliWallet);

const deposit_contract = new ethers.Contract(deposit_addr, deposit_contractABI, goerliWallet);
deposit_contract.connect(goerliWallet);

const approve_contract = new ethers.Contract(gsb_addr, gsb_contractABI, goerliWallet);
approve_contract.connect(goerliWallet);

const withdraw_contract = new ethers.Contract(withdraw_addr, withdraw_contractABI, gnosisWallet);
withdraw_contract.connect(gnosisWallet);

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
        69420
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
            gasLimit: 200000,
        }
    )
    console.log(tx);
    console.log(await tx.wait())
    console.log("deposit done");

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
