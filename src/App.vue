<template>
    <ElContainer direction="vertical" class="h-[100vh] space-y-10">
        <el-menu mode="horizontal" :ellipsis="false">
            <div class="flex items-center flex justify-center w-1/6">
                <strong class="text-2xl"> 房屋買賣系統 </strong>
            </div>
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
            <el-menu-item index="6" v-show="status == 'authenticated'" @click="checkContractExist">
                <strong> checkContract </strong>
            </el-menu-item>
            <el-menu-item index="7" v-show="status == 'authenticated'" @click="testButton">
                <strong> testButton </strong>
            </el-menu-item>
        </el-menu>
        <div class="flex justify-center" v-show="status == 'authenticated'">
            <div class="w-4/5">
                <el-menu @select="refreshTable" :default-active="activeIndex" mode="horizontal" :ellipsis="false">
                    <el-menu-item index="0">
                        <strong> All house </strong>
                    </el-menu-item>
                    <el-menu-item index="1">
                        <strong> My house </strong>
                    </el-menu-item>
                    <div class="flex-grow" />
                    <div class="flex items-center flex justify-end w-1/6" v-show="activeIndex == '1'">
                    </div>
                </el-menu>
                <ElContainer v-show="activeIndex == '0'">
                    <el-table :data="houseInfo">
                        <el-table-column prop="tokenId" label="tokenId" width="100" />
                        <el-table-column prop="owner" label="house_owner" width="300" />
                        <el-table-column prop="price" label="price" />
                        <el-table-column prop="sell" label="sell" />
                        <el-table-column prop="data" label="ipfs-image-link" />
                        <el-table-column label="buy">
                            <template v-slot="{ row }">
                                <ElButton :disabled="!row.sell && owner != userAddress" type="primary"
                                    @click="buy_house(row.tokenId)">buy</ElButton>
                            </template>
                        </el-table-column>
                        <el-table-column label="detailed">
                            <ElButton type="primary" @click="detailed">detailed</ElButton>
                        </el-table-column>
                    </el-table>
                </ElContainer>
                <div>
                    <ul>
                        <li v-for="item in jsonData" :key="item.id">{{ item.name }}</li>
                    </ul>
                </div>
                <ElContainer v-show="activeIndex == '1'">
                    <el-table :data="houseInfo">
                        <el-table-column prop="tokenId" label="tokenId" width="100" />
                        <el-table-column prop="owner" label="house_owner" width="300" />
                        <el-table-column prop="price" label="price" />
                        <el-table-column prop="sell" label="sell" />
                        <el-table-column label="modify">
                            <template v-slot="{ row }">
                                <ElButton type="primary" @click="showModifyDialog(row)" :icon="Edit" />
                            </template>
                        </el-table-column>
                        <el-table-column label="delete">
                            <template v-slot="{ row }">
                                <ElButton type="primary" @click="_delete(row.tokenId)" :icon="Delete" />
                            </template>
                        </el-table-column>
                    </el-table>
                </ElContainer>
                <div class="fixed bottom-20 right-20 z-50" v-show="activeIndex == '1'">
                    <ElButton type="primary" @click="dialogAddVisible = true" circle :icon="Plus" size="large" />
                </div>
                <el-dialog v-model="dialogAddVisible" title="Add House">
                    <el-form :model="form">
                        <el-form-item label="TokenID" :label-width="formLabelWidth">
                            <el-input v-model="addForm.token_id" autocomplete="off" />
                        </el-form-item>
                        <el-form-item label="Price" :label-width="formLabelWidth">
                            <el-input v-model="addForm.price" autocomplete="off" />
                        </el-form-item>
                        <el-form-item label="URI" :label-width="formLabelWidth">
                            <el-input v-model="addForm.URI" autocomplete="off" />
                        </el-form-item>
                    </el-form>
                    <template #footer>
                        <span class="dialog-footer">
                            <el-button @click="dialogAddVisible = false">Cancel</el-button>
                            <el-button type="primary" @click="Add_house()">Add</el-button>
                        </span>
                    </template>
                </el-dialog>
                <el-dialog v-model="dialogModifyVisible" title="Modify house">
                    <el-form :model="modifyForm" label-width="70px">
                        <el-form-item label="price">
                            <el-input v-model="modifyForm.price" autocomplete="off" />
                        </el-form-item>
                        <el-form-item label="sell">
                            <el-select v-model="modifyForm.sell" placeholder="Select">
                                <el-option v-for="item in [{ key: 'true', value: true }, { key: 'false', value: false }]"
                                    :key="item.value" :value="item.value" />
                            </el-select>
                        </el-form-item>
                        <el-form-item label="uri">
                            <el-input v-model="modifyForm.URI" autocomplete="off" />
                        </el-form-item>
                    </el-form>
                    <template #footer>
                        <span class="dialog-footer">
                            <el-button @click="dialogModifyVisible = false">Cancel</el-button>
                            <el-button type="primary" @click="confirmModify">
                                Confirm
                            </el-button>
                        </span>
                    </template>
                </el-dialog>
            </div>
        </div>
    </ElContainer>
</template>

<script setup >
import { ethers } from 'ethers'
import { contractABI, contractAddress } from './contract'
import { ElButton, ElContainer, ElMessage, ElMessageBox } from 'element-plus';
import { Delete, Edit, Plus } from '@element-plus/icons-vue'
import { ref, markRaw, reactive } from 'vue';
// import axios from 'axios';

// const info = reactive({
//     address: "",
//     built_date: "",
//     category: "",
//     story: "",
//     size: "",
//     description: "",
//     image : " "
// })
console.log('ethers version:', ethers.version);

const formLabelWidth = '140px'
let status = ref("unauthenticated");
let userAddress = ref();
let houseInfo = ref();
let activeIndex = ref('0');
let dialogModifyVisible = ref(0);
let dialogAddVisible = ref(false)
let modifyForm = reactive({
    tokenId: '',
    price: '',
    sell: '',
    URI: ''
});
let addForm = reactive({
    address: "",
    token_id: "",
    price: "",
})


// const info = reactive({
//     address: "",
//     built_date: "",
//     category: "",
//     story: "",
//     size: "",
//     description: "",
//     image : " "
// })

// avoid ResizeObserver error
const debounce = (fn, delay) => {
    let timer = null;
    return function () {
        let context = this;
        let args = arguments;
        clearTimeout(timer);
        timer = setTimeout(function () {
            fn.apply(context, args);
        }, delay);
    }
}

// avoid ResizeObserver error
const _ResizeObserver = window.ResizeObserver;
window.ResizeObserver = class ResizeObserver extends _ResizeObserver {
    constructor(callback) {
        callback = debounce(callback, 16);
        super(callback);
    }
}

async function confirmModify() {
    console.log("modify house");
    console.log(modifyForm);
    const contract = Contract();
    try {
        await contract.set_sell(modifyForm.tokenId, modifyForm.sell);
    }
    catch (e) {
        console.log(e);
    }
    await contract.set_house_price(modifyForm.tokenId, modifyForm.price);
    modifyForm.URI && await contract.setTokenURI(modifyForm.tokenId, modifyForm.URI);
    dialogModifyVisible.value = false;
    console.log("modify house finish")
    my_house();
}

async function showModifyDialog(row) {
    dialogModifyVisible.value = true;
    console.log(row.tokenId);
    const contract = Contract();
    Object.assign(modifyForm, {
        tokenId: row.tokenId,
        price: row.price,
        sell: row.sell,
        URI: await contract.tokenURI(row.tokenId)
    })

    console.log(modifyForm)
}

async function _delete(tokenId) {
    ElMessageBox.confirm(
        'It will permanently delete the house. Continue?',
        'Warning',
        {
            type: 'warning',
            icon: markRaw(Delete),
        }
    ).then(async function () {
        const contract = Contract();
        const tx = await contract.burn_house(tokenId);
        await tx.wait();
        my_house();
        console.log("delete house " + tokenId);
        ElMessage({ message: 'Delete house ' + tokenId, type: 'success' });
    }).catch(() => {
        console.log('Cancel delete');
        ElMessage({ message: 'Cancel delete', type: 'info' });
    })
}

async function refreshTable(index) {
    switch (index) {
        case "0":
            await all_house();
            activeIndex.value = "0";
            console.log("all_house")
            break;

        case "1":
            await my_house();
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
        const tokenURI = await contract.tokenURI(tokenId)
        if (tokenURI == "") {
            return {
                tokenId,
                owner,
                price,
                sell,
                tokenURI,
                data: "Have no image."
            };
        }
        // const ipfs = await axios.get('https://gateway.pinata.cloud/ipfs/'+ tokenURI)
        const axios = require('axios');
        const ipfs = await axios.get('https://gateway.pinata.cloud/ipfs/' + tokenURI)
        const data = ipfs.data.image
        console.log(ipfs.data)
        return {
            tokenId,
            owner,
            price,
            sell,
            tokenURI,
            data
        };
    }));
    houseInfo.value = all_house;
}
// userAddress.value
async function Add_house() {
    const address = userAddress.value;
    const contract = Contract();
    try {
        await contract.mint_house(address, addForm.token_id, addForm.price);
        ElMessage({ message: '增加成功', type: 'success' });
    }
    catch (err) {
        let message = err['data']['data']['reason'] || err['message'];
        ElMessage({ message: message });
    }
    my_house();
    dialogAddVisible.value = false;
}

async function buy_house(tokenId) {
    console.log(tokenId);
    const contract = Contract();
    try {
        await contract.buy_house(tokenId);
        ElMessage({ message: '購買成功' });
        refreshTable(activeIndex.value);
    }
    catch (err) {
        let message = err['data']['data']['reason'] || err['message'];
        ElMessage({ message: message });
    }
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

async function checkContractExist() {
    const provider = Provider();
    provider.getCode('0x3DED0e7f88a8C5a7afA2af440B79d0C4E6c9052B').then((code) => {
        if (code === '0x') {
            console.log('Contract does not exist in the blockchain');
        } else {
            console.log('Contract exists in the blockchain');
        }
    });
}

async function testButton() {
    const contract = Contract();
    let balance = await contract.moneyBalanceOf('0x5b2a467EDBC5b71fc73E3925863AaD3dAA965A19');
    console.log(balance);
    console.log("finish");
}

</script>
<style>
.flex-grow {
    flex-grow: 1;
}
</style>