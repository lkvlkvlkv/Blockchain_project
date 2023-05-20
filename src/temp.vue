<template>
    <TH class = "up">
        <button  class = "log_out">Log Out</button>
        <!-- <button class = "log_in">Log In</button> -->
        <div v-show="!userAddress">
            <button @click="checkLogin" class = "log_in">Log In</button>
        </div>
        <th-text-start class = "title">House Trading System</th-text-start>
        <div v-show="userAddress">
            <span>User Address: {{ userAddress }}</span>
        </div>
    </TH>
    <div v-show="ownerAddress && checked_tokenId1">
        <span>Owner of tokenId={{ checked_tokenId1 }} is address={{ ownerAddress }}</span>
    </div>
    <div v-show="checked_addressTo && checked_tokenId2">
        <span>Give tokenId={{ checked_tokenId2 }} to address={{ checked_addressTo }}</span>
    </div>
    <span v-show="userAddress">
    <TH class = "bottom">
        <input type="text" class = "A" placeholder = "Uint256 Token ID" v-model="checked_tokenId1">
        <input type="text" class = "B" placeholder = "Address To" v-model="addressTo">
        <input type="text" class = "C" placeholder = "Uint256 Token ID" v-model="checked_tokenId2">
        <input type="text" class = "D" placeholder = "Other Function" >
        <button class = "owner" @click="ownerOf">Owner Of</button>
        <button class = "mint" @click="mint">Mint</button>
        <button class = "function">Other Function</button>
    </TH>
    </span>

</template>

<style scoped>
/* Your styles here */
TH.up{
    position: absolute;
    width: 1393px;
    height: 117px;
    left: 0px;
    top: 0px;

    background: #F8FB79;
    border: 1px solid #FFFFFF;
    backdrop-filter: blur(2px);
}
TH.bottom{
    box-sizing: border-box;
    /* Auto layout */
    display: flex;
    flex-direction: row;
    align-items: flex-start;
    /* padding: 10px 10px 733px; */
    gap: 10px;
    isolation: isolate;

    position: absolute;
    width: 1010px;
    height: 480px;
    left: 200px;
    top: 134px;

    background: #D4D4D4;
    border: 1px solid #FFFFFF;
    box-shadow: 0px 4px 4px rgba(0, 0, 0, 0.25);
    border-radius: 30px;
}
button.log_out{
    /* v-btn */
    box-sizing: border-box;
    /* Auto layout */
    display: flex;
    flex-direction: row;
    align-items: center;
    padding: 0px 16px;
    gap: 16px;

    position: absolute;
    width: 105px;
    height: 34px;
    left: 1250px;
    top: 41px;

    background: #19D237;
    /* black/0.87 */
    border: 1px solid rgba(0, 0, 0, 0.87);
    box-shadow: 0px 4px 4px rgba(0, 0, 0, 0.25);
    border-radius: 4px;
}
button.log_in{
    /* v-btn */
    box-sizing: border-box;
    /* Auto layout */
    display: flex;
    flex-direction: row;
    align-items: center;
    padding: 0px 16px;
    gap: 16px;

    position: absolute;
    width: 107px;
    height: 34px;
    left: 1120px;
    top: 41px;

    background: #19D237;
    /* black/0.87 */
    border: 1px solid rgba(0, 0, 0, 0.87);
    box-shadow: 0px 4px 4px rgba(0, 0, 0, 0.25);
    border-radius: 4px;
}
input.A{
    position: absolute;
    width: 450px;
    height: 50px;
    left: 200px;
    top: 70px;

    background: #FFFFFF;
    /* default */
    box-shadow: 0px 1px 1px rgba(0, 0, 0, 0.2), 0px 2px 2px rgba(0, 0, 0, 0.14), 0px 1px 5px rgba(0, 0, 0, 0.12);
    border-radius: 10px;
}
input.B{
    position: absolute;
    width: 220px;
    height: 50px;
    left: 200px;
    top: 160px;

    background: #FFFFFF;
    /* default */
    box-shadow: 0px 1px 1px rgba(0, 0, 0, 0.2), 0px 2px 2px rgba(0, 0, 0, 0.14), 0px 1px 5px rgba(0, 0, 0, 0.12);
    border-radius: 10px;
}
input.C{
    position: absolute;
    width: 220px;
    height: 50px;
    left: 430px;
    top: 160px;

    background: #FFFFFF;
    /* default */
    box-shadow: 0px 1px 1px rgba(0, 0, 0, 0.2), 0px 2px 2px rgba(0, 0, 0, 0.14), 0px 1px 5px rgba(0, 0, 0, 0.12);
    border-radius: 10px;
}
input.D{
    position: absolute;
    width: 450px;
    height: 50px;
    left: 200px;
    top: 250px;

    background: #FFFFFF;
    /* default */
    box-shadow: 0px 1px 1px rgba(0, 0, 0, 0.2), 0px 2px 2px rgba(0, 0, 0, 0.14), 0px 1px 5px rgba(0, 0, 0, 0.12);
    border-radius: 10px;
}
button.owner{
    position: absolute;
    width: 107px;
    height: 50px;
    left: 700px;
    top: 70px;

    background: #00E5E5;
    /* black/0.87 */

    border: 1px solid rgba(0, 0, 0, 0.87);
    box-shadow: 0px 4px 4px rgba(0, 0, 0, 0.25);
    border-radius: 10px;
}
button.mint{
    position: absolute;
    width: 107px;
    height: 50px;
    left: 700px;
    top: 160px;
    background: #00E5E5;
    /* black/0.87 */

    border: 1px solid rgba(0, 0, 0, 0.87);
    box-shadow: 0px 4px 4px rgba(0, 0, 0, 0.25);
    border-radius: 10px;
}
button.function{
    position: absolute;
    width: 107px;
    height: 50px;
    left: 700px;
    top: 250px;
    background: #00E5E5;
    /* black/0.87 */

    border: 1px solid rgba(0, 0, 0, 0.87);
    box-shadow: 0px 4px 4px rgba(0, 0, 0, 0.25);
    border-radius: 10px;
}

th-text-start.title{
    display: flex;
    flex-direction: row;
    align-items: center;
    padding: 10px 16px;
    gap: 10px;

    position: absolute;
    width: 287px;
    height: 100px;
    left: 0px;
    top: 0px;

}
</style>

<script>
import { ethers } from 'ethers'
// import Web3 from 'web3'
import { contractABI, contractAddress } from './contract'

console.log('ethers version:', ethers.version);

export default {
    name: "App",
    data() {
        return {
            activeIndex: "1",
            activeIndex2: "1",
            userAddress: "",
            ownerAddress: "",
            tokenId1: "",
            checked_tokenId1: "",
            tokenId2: "",
            checked_tokenId2: "",
            tokenId3: "",
            addressTo: "",
            checked_addressTo: ""
        };
    },
    methods: {
        handleSelect(key, keyPath) {
            console.log(key, keyPath);
        },
        async checkLogin() {
            const { ethereum } = window;
            if (!ethereum) {
                alert("請安裝metamask錢包");
                return;
            }
            console.log("您已安裝metamask");
            const [account] = await window.ethereum.request({ method: "eth_requestAccounts" });
            this.userAddress = account;
        },
        Provider() {
            return new ethers.providers.Web3Provider(window.ethereum);
        },
        Contract() {
            const Provider = this.Provider();
            const signer = Provider.getSigner();
            const contract = new ethers.Contract(contractAddress, contractABI, signer);
            return contract;
        },
        async ownerOf() {
            const contract = this.Contract();
            const result = await contract.ownerOf(this.tokenId1);
            this.ownerAddress = result;
            this.checked_tokenId1 = this.tokenId1;
        },
        async mint() {
            const contract = this.Contract();
            await contract.mint(this.addressTo, this.tokenId2);
            this.checked_tokenId2 = this.tokenId2;
            this.checked_addressTo = this.addressTo;
        }
    },
}

</script>

<style>
#app {
    font-family: Avenir, Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;
    margin-top: 60px;
}
</style>
