// Listen for event submitted by the AMB
// Call executeMessage() to Gnosis AMB

import axios from "axios";
import {ethers} from "ethers";

const provider = new ethers.providers.JsonRpcProvider(
    "https://rpc.ankr.com/gnosis",
);
console.log(process.env.GNOSIS_PRIVATE_KEY);

const wallet = new ethers.Wallet(process.env.GNOSIS_PRIVATE_KEY, provider);

const gnosis_amb_addr = "0xBf5dB0765E7D820CBBfbf7020668F5D34f48D93d"
const gnosis_amb_contractABI = ["function executeMessage(uint64 slot, bytes calldata message, bytes[] calldata accountProof, bytes[] calldata storageProof)"]
const gnosis_amb_contract = new ethers.Contract(gnosis_amb_addr, gnosis_amb_contractABI, wallet);
gnosis_amb_contract.connect(wallet);

const goerli_amb_contract = "0x68787ab0ca5a4a8cc82177b4e4f206765ce39956"


import Stomp from "stompjs"

let url = "wss://api.covalenthq.com/v1/";
let c = Stomp.overWS(url);
let timeout = 5000;
c.heartbeat.incoming = 0;
c.heartbeat.outgoing = 10000;

function successCallback() {
    let sub1 = c.subscribe("/v1/1/events/address/" + goerli_amb_contract + "/", function (message) {
        // user can do anything with message.body because it is the log event object returned
        console.log("This is sub1 data: " + message.body)
    });

}

c.connect( "ckey_f6a51a0e21004ad29ebabc70660", "", function (frame) {
    console.log("Connected: " + frame);
    successCallback();
}, function (error) {
    console.log("You disconnected: " + error);
    c.disconnect(function () {
        setTimeout(() => {
            reconnect("wss://api.covalenthq.com/v1/", successCallback);
        }, timeout);
    });
});

let mytimeOut;
function reconnect(socketUrl, successCallback) {
    if (c.connected) {
        c.disconnect();
        return;
    }

    clearTimeout(mytimeOut);
    console.log("Trying to reconnect...");
    let connected = false;

    c = Stomp.overWS(socketUrl);
    c.heartbeat.incoming = 0;
    c.heartbeat.outgoing = 10000;
    c.connect({}, (frame) => {
        connected = true;
        successCallback();
        timeout = 5000;
        clearTimeout(mytimeOut);
    }, () => {
        if (connected) {
            setTimeout(() => {
                reconnect(socketUrl, successCallback);
            }, timeout);
        }
    });
    if (!c.connected) {
        mytimeOut = setTimeout(() => {
            reconnect(socketUrl, successCallback);
        }, timeout += 1000);
    }
}


//
// const covalentURL = "https://api.covalenthq.com/v1/5/events/address/" + goerli_amb_contract + "/?quote-currency=USD&format=JSON&starting-block=7898242&ending-block=latest&key=ckey_f6a51a0e21004ad29ebabc70660"
//
// const resp = await axios.get(covalentURL, {
//     auth: {
//         username: "ckey_f6a51a0e21004ad29ebabc70660",
//         password: ""
//     }
// })
//
// const items = resp.data.data.items
//
// items.slice(0, 1).forEach(async item => {
//     console.log("Processing transaction " + item.tx_hash)
//     const message = item.raw_log_data;
//     const gnosis_tx = await gnosis_amb_contract.executeMessage(
//         0,
//         message,
//         [],
//         [],
//         {
//             gasLimit: 500000
//         }
//     )
//     console.log(gnosis_tx)
//     console.log(gnosis_tx.wait())
//     console.log("executeMessage done")
// })
//
