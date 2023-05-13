<template>
    <img alt="Vue logo" src="./assets/logo.png" />
    <div v-show="!userAddress">
        <button @click="checkLogin">登入</button>
    </div>
    <div v-show="userAddress">
        <span>User Address: {{ userAddress }}</span>
    </div>
    <ul class="button-list">
        <li>
            <span v-show="userAddress">
                <button @click="ownerOf">ownerOf</button>
            </span>
            <span v-show="userAddress">
                <input type="text" placeholder="uint256 tokenId" v-model="tokenId">
            </span>
        </li>
        <li>
            <div v-show="ownerAddress">
                <span>Owner of tokenId={{ tokenId }} is address={{ ownerAddress }}</span>
            </div>
        </li>
        <li>
            <span v-show="userAddress">
                <button @click="ownerOf">ownerOf</button>
            </span>
            <span v-show="userAddress">
                <input type="text" placeholder="uint256 tokenId" v-model="tokenId">
            </span>
        </li>
        <li>
            <span v-show="userAddress">
                <button @click="ownerOf">ownerOf</button>
            </span>
            <span v-show="userAddress">
                <input type="text" placeholder="uint256 tokenId" v-model="tokenId">
            </span>
        </li>
  </ul>
</template>

<style scoped>
/* Your styles here */
ul.button-list {
    list-style-type: none;
    margin: 0;
    padding: 0;
}

ul.button-list li {
    display: inline-block;
    margin-right: 10px;
}

button {
    background-color: #4CAF50;
    border: none;
    color: white;
    padding: 10px 20px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 16px;
    margin: 4px 2px;
    cursor: pointer;
}
</style>


<script>
import { ethers } from 'ethers'
// import Web3 from 'web3'
import { contractABI, contractAddress } from './contract'

console.log('ethers version:', ethers.version);

export default {
    name: 'App',
    data() {
        return {
            userAddress: "",
            ownerAddress: "",
            tokenId: ""
        }
    },
    methods: {
        async checkLogin() {
            const { ethereum } = window
            if (!ethereum) {
                alert("請安裝metamask錢包")
                return
            }
            console.log("您已安裝metamask")
            const [account] = await window.ethereum.request({ method: 'eth_requestAccounts' })
            this.userAddress = account
        },
        Provider() {
            return new ethers.providers.Web3Provider(window.ethereum)
        },
        Contract() {
            const Provider = this.Provider()
            const signer = Provider.getSigner()
            const contract = new ethers.Contract(contractAddress, contractABI, signer)
            return contract
        },
        async ownerOf() {
            // console.log(this.tokenId)
            // console.log(tokenId1)
            const contract = this.Contract();
            const result = await contract.ownerOf(this.tokenId)
            this.ownerAddress = result
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
