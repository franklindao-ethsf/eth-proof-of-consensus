// Listen for event submitted by the AMB
// Call executeMessage() to Gnosis AMB

import axios from "axios";
import {ethers} from "ethers";

const gnosisprovider = new ethers.providers.JsonRpcProvider(
    process.env.GNOSIS_RPC_URL,
);
const gnosisWallet = new ethers.Wallet(process.env.GNOSIS_PRIVATE_KEY, gnosisprovider);
const gnosis_amb_addr = "0x4A55AB2AC6367A28ff22dC87376673B5d4F23B91"
const gnosis_amb_contractABI = ["function executeMessage(uint64 slot, bytes calldata message, bytes[] calldata accountProof, bytes[] calldata storageProof)"]
const gnosis_amb_contract = new ethers.Contract(gnosis_amb_addr, gnosis_amb_contractABI, gnosisWallet);
gnosis_amb_contract.connect(gnosisWallet);

const apiKey = "-pZDSyH8gXs_PdlVenq0wJz_m7YaZfTp";

const alchemyProvider = new ethers.providers.AlchemyProvider("goerli", apiKey);

const goerliprovider = new ethers.providers.JsonRpcProvider(
    process.env.GOERLI_RPC_URL,
);
const goerliWallet = new ethers.Wallet(process.env.GOERLI_PRIVATE_KEY, goerliprovider);
const goerli_amb_addr = "0x0483eFdC8BDf3582Ba6f9A805d777ac2f7Cb8d42"
const goerli_amb_contractABI = ["function executeMessage(uint64 slot, bytes calldata message, bytes[] calldata accountProof, bytes[] calldata storageProof)"]
const goerli_amb_contract = new ethers.Contract(goerli_amb_addr, goerli_amb_contractABI, goerliWallet);
goerli_amb_contract.connect(goerliWallet);

const optimismprovider = new ethers.providers.JsonRpcProvider(
    process.env.POLYGON_RPC_URL,
);
const optimismWallet = new ethers.Wallet(process.env.POLYGON_PRIVATE_KEY, optimismprovider);
const optimism_amb_addr = "0x0483eFdC8BDf3582Ba6f9A805d777ac2f7Cb8d42"
const optimism_amb_contractABI = ["function executeMessage(uint64 slot, bytes calldata message, bytes[] calldata accountProof, bytes[] calldata storageProof)"]
const optimism_amb_contract = new ethers.Contract(optimism_amb_addr, optimism_amb_contractABI, optimismWallet);
optimism_amb_contract.connect(optimismWallet);

let lastBlock = 7901325;

const emit = async item => {
    console.log("Processing transaction " + item.tx_hash)
    let message = item.raw_log_data;
    message = "0x" + message.slice(130);
    console.log(message);
    const chainIdHex = item.raw_log_data.slice(384, 386);
    const chainId = parseInt(chainIdHex, 16);
    const block = item.block_height;
    if (block > lastBlock) {
        lastBlock = block + 1;
    }
    const account = await alchemyProvider.send("eth_getProof", [
        '0x68787ab0ca5a4a8cc82177b4e4f206765ce39956', // amb address
        [item.raw_log_topics[2]], // topic 2
        "0x" + block.toString(16)]
    );

    if (chainId === 100) {
        const gnosis_tx = await gnosis_amb_contract.executeMessage(
            4264288,
            message,
            account.accountProof,
            account.storageProof[0].proof,
            {
                gasLimit: 500000
            }
        )
        console.log(await gnosis_tx.wait())
        console.log("executeMessage done")
    } else {
        const optimism_tx = await optimism_amb_contract.executeMessage(
            4264288,
            message,
            account.accountProof,
            account.storageProof[0].proof,
            {
                gasLimit: 500000
            }
        )
        console.log(await optimism_tx.wait())
        console.log("executeMessage done")
    }
}

while (true) {
    console.log("Checking for new transactions")
    const covalentURL = "https://api.covalenthq.com/v1/5/events/address/" + goerli_amb_contract + "/?quote-currency=USD&format=JSON&starting-block=" + lastBlock + "&ending-block=latest&key=ckey_f6a51a0e21004ad29ebabc70660"
    const resp = await axios.get(covalentURL, {
        auth: {
            username: "ckey_f6a51a0e21004ad29ebabc70660",
            password: ""
        }
    })

    const items = resp.data.data.items

    for (let i = 0; i < items.length; i++) {
        await emit(items[i])
    }

    await new Promise(r => setTimeout(r, 1000));
}
