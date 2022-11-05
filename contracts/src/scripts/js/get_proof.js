
import {ethers} from 'ethers'

async function main() {
  
   const apiKey = "-pZDSyH8gXs_PdlVenq0wJz_m7YaZfTp";

   const provider = new ethers.providers.AlchemyProvider("goerli", apiKey);

   // https://eips.ethereum.org/EIPS/eip-1186
   // Query the blockchain (replace example parameters)
   const block = 7898688; // corr to slot 4264288
   const account = await provider.send("eth_getProof", [
       '0x68787ab0ca5a4a8cc82177b4e4f206765ce39956', // amb address
       ['0x746ed90a642329f42a30950862d821bcba6358eb46fd53267b88d714a71e00b9'], // topic 2
       "0x" + block.toString(16)]
     ); 
   
   // Print the output to console
   console.log(account);
   console.log(account.storageProof[0]);
  }
  main()
