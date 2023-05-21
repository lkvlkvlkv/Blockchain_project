<template>
    <ElContainer direction="vertical" class="h-[100vh] space-y-10">
        <el-menu mode="horizontal" :ellipsis="false">
            <el-menu-item index="0">
                <strong> House Trading System </strong>
            </el-menu-item>
            <div class="flex-grow" />
            <el-menu-item index="1" v-show="status == 'unauthenticated'" @click="checkLogin">
                <strong> Log In </strong>
            </el-menu-item>
            <el-menu-item index="2" v-show="status == 'authenticated'" @click="Welcome">
                <strong> Show address </strong>
            </el-menu-item>
            <el-menu-item index="5" v-show="status == 'authenticated'" @click="houseBalanceOf">
                <strong> houseBalanceOf </strong>
            </el-menu-item>
            <el-menu-item index="6" v-show="status == 'authenticated'" @click="switch_page">
                <strong> tested </strong>
            </el-menu-item>
        </el-menu>
        <div class="flex justify-center" v-show="status == 'authenticated'">
            <div class="w-4/5">
                <el-menu @select="handleSelect" :default-active="activeIndex" mode="horizontal" :ellipsis="false">
                    <el-menu-item index="0">
                        <strong> All house </strong>
                    </el-menu-item>
                    <el-menu-item index="1">
                        <strong> My house </strong>
                    </el-menu-item>
                    <div class="flex-grow" />
                    <div class="flex items-center flex justify-end w-1/6">
                        <ElButton type="primary" @click="Add">Add</ElButton>
                    </div>
                </el-menu>
                <ElContainer v-show="activeIndex == '0'">
                    <el-table :data="houseInfo">
                        <el-table-column prop="tokenId" label="tokenId" width="100" />
                        <el-table-column prop="owner" label="house_owner" width="300" />
                        <el-table-column prop="price" label="price" />
                        <el-table-column prop="sell" label="sell" />
                        <el-table-column label="buy">
                            <ElButton type="primary" @click="my_house" style="color:blue!">buy</ElButton>
                        </el-table-column>
                        <el-table-column label="contact">
                            <ElButton type="primary" @click="contact">contact</ElButton>
                        </el-table-column>
                    </el-table>
                </ElContainer>
                <ElContainer v-show="activeIndex == '1'">
                    <el-table :data="houseInfo">
                        <el-table-column prop="tokenId" label="tokenId" width="100" />
                        <el-table-column prop="owner" label="house_owner" width="300" />
                        <el-table-column prop="price" label="price" />
                        <el-table-column prop="sell" label="sell" />
                        <el-table-column label="buy">
                            <ElButton type="primary" @click="modify">modify</ElButton>
                        </el-table-column>
                        <el-table-column label="contact">
                            <ElButton type="primary" @click="XDD">delete</ElButton>
                        </el-table-column>
                    </el-table>
                </ElContainer>
            </div>
        </div>
    </ElContainer>
</template>

<script setup>
import { ethers } from 'ethers'
import { contractABI, contractAddress } from './contract'
import { ElContainer, ElMessage } from 'element-plus';
import { ref } from 'vue'

console.log('ethers version:', ethers.version);

let status = ref("unauthenticated");
let userAddress = ref();
let houseInfo = ref();
let activeIndex = ref('0')

async function handleSelect(index) {
    switch (index) {
        case "0":
            all_house();
            activeIndex.value = "0";
            console.log("all_house")
            break;

        case "1":
            my_house();
            activeIndex.value = "1";
            console.log("my_house")
            break;
        default:
            break;
    }
}

function Welcome() {
    ElMessage({ message: 'Welcome, your address is ' + userAddress.value, type: 'success' });
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

async function my_house() {
    const contract = Contract();
    let my_house = await contract.my_house();
    my_house = await Promise.all(my_house.map(async (element) => {
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
    houseInfo.value = my_house;
}

async function houseBalanceOf() {
    const contract = Contract();
    const balance = await contract.houseBalanceOf(userAddress.value);
    ElMessage({ message: '您擁有' + balance + '棟房子', type: 'success' });
}

</script>
<style>
.flex-grow {
    flex-grow: 1;
}
</style>