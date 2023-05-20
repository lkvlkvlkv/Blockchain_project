<template>
    <ElContainer direction="vertical" class="h-[100vh]">
        <el-menu
            :default-active="activeIndex"
            class="el-menu-demo"
            mode="horizontal"
            :ellipsis="false"
        >
            <el-menu-item index="0">
                <strong> House Trading System </strong>
            </el-menu-item>
            <div class="flex-grow" />
            <el-menu-item index="1" v-show="status=='unauthenticated'" @click="checkLogin">
                <strong> Log In </strong>
            </el-menu-item>
            <el-menu-item index="2" v-show="status=='authenticated'" @click="Welcome">
                <strong> Show address </strong>
            </el-menu-item>
            <el-menu-item index="3" v-show="status=='authenticated'" @click="all_house">
                <strong> all_house </strong>
            </el-menu-item>
            <el-menu-item index="3" v-show="status=='authenticated'" @click="test">
                <strong> house_owner </strong>
            </el-menu-item>
        </el-menu>
    </ElContainer>
    <ElContainer v-show="status=='authenticated'">
        <el-table :data="houseInfo">
            <el-table-column prop="tokenId" label="tokenId" width="100"/>
            <el-table-column prop="owner" label="house_owner" width="300"/>
            <el-table-column prop="price" label="price"/>
            <el-table-column prop="sell" label="sell"/>
            <el-table-column label="buy">
                <ElButton type="primary" @click="buy_house">buy</ElButton>
            </el-table-column>
            <el-table-column label="contact">
                <ElButton type="primary" @click="contact">buy</ElButton>
            </el-table-column>
        </el-table>
    </ElContainer>
</template>

<script setup>
import { ethers } from 'ethers'
import { contractABI, contractAddress } from './contract'
import { ElButton, ElContainer, ElMessage } from 'element-plus';
import { ref } from 'vue'

console.log('ethers version:', ethers.version);

let status = ref("unauthenticated");
let userAddress = ref();
let houseInfo = ref();

function Welcome() {
    ElMessage({message:'Welcome, your address is ' + userAddress.value, type: 'success'});
}

async function checkLogin() {
    console.log("checkLogin")
    const { ethereum } = window;
    if (!ethereum) {
        alert("請安裝metamask錢包");
        return;
    }
    console.log("您已安裝metamask");
    const [account] = await window.ethereum.request({ method: "eth_requestAccounts" });
    userAddress.value = account;
    status.value = "authenticated";
    Welcome();
    all_house();
}
function Provider() {
    return new ethers.providers.Web3Provider(window.ethereum);
}
function Contract() {
    const provider = Provider();
    const signer = provider.getSigner();
    const contract = new ethers.Contract(contractAddress, contractABI, signer);
    return contract;
}

async function all_house() {
    const contract = Contract();
    let all_house = await contract.all_house();
    all_house = await Promise.all(all_house.map(async (element) => {
        const tokenId = element.toString();
        const owner = await house_owner(element);
        const price = await search_price(element);
        const sell = await search_sell(element);
        
        return {
            tokenId,
            owner,
            price,
            sell
        };
    }));
    houseInfo.value = all_house;
    console.log(houseInfo.value);
}

async function search_price(tokenId) {
    const contract = Contract();
    const price = await contract.search_price(tokenId);
    return price;
}

async function search_sell(tokenId) {
    const contract = Contract();
    const sell = await contract.search_sell(tokenId);
    return sell;
}

async function house_owner(tokenId) {
    const contract = Contract();
    const house_owner = await contract.house_owner(tokenId);
    return house_owner;
}

</script>
<style>
.flex-grow {
  flex-grow: 1;
}
</style>