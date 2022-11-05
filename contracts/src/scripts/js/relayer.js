// Listen for event submitted by the AMB
// Call executeMessage() to Gnosis AMB

import axios from "axios";
import {ethers} from "ethers";

const provider = new ethers.providers.JsonRpcProvider(
    "https://rpc.ankr.com/gnosis",
);
console.log(process.env.GNOSIS_PRIVATE_KEY);

const wallet = new ethers.Wallet(process.env.GNOSIS_PRIVATE_KEY, provider);

const gnosis_amb_addr = "0x11f4b338c6127f0939d3d7cd56b1c9e6c4a68725"
const gnosis_amb_contractABI = ["function executeMessage(uint64 slot, bytes calldata message, bytes[] calldata accountProof, bytes[] calldata storageProof)"]
const gnosis_amb_contract = new ethers.Contract(gnosis_amb_addr, gnosis_amb_contractABI, wallet);
gnosis_amb_contract.connect(wallet);

const apiKey = "-pZDSyH8gXs_PdlVenq0wJz_m7YaZfTp";

const alchemyProvider = new ethers.providers.AlchemyProvider("goerli", apiKey);

const goerli_amb_contract = "0x68787ab0ca5a4a8cc82177b4e4f206765ce39956"

const covalentURL = "https://api.covalenthq.com/v1/5/events/address/" + goerli_amb_contract + "/?quote-currency=USD&format=JSON&starting-block=7898242&ending-block=latest&key=ckey_f6a51a0e21004ad29ebabc70660"

const resp = await axios.get(covalentURL, {
    auth: {
        username: "ckey_f6a51a0e21004ad29ebabc70660",
        password: ""
    }
})

const items = resp.data.data.items

items.slice(items.length - 1).forEach(async item => {
    console.log("Processing transaction " + item.tx_hash)
    const message = item.raw_log_data;
    const block = item.block_height;
    const account = await alchemyProvider.send("eth_getProof", [
        '0x68787ab0ca5a4a8cc82177b4e4f206765ce39956', // amb address
        [item.raw_log_topics[2]], // topic 2
        "0x" + block.toString(16)]
    );

    const gnosis_tx = await gnosis_amb_contract.executeMessage(
        4264288,
        message,
        account.accountProof,
        account.storageProof[0].proof,
        {
            gasLimit: 500000
        }
    )
    console.log(gnosis_tx)
    console.log(gnosis_tx.wait())
    console.log("executeMessage done")
})

