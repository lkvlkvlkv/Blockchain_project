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
            <el-menu-item index="3" v-show="status == 'authenticated'" @click="moneyBalanceOf">
                <strong> moneyBalanceOf </strong>
            </el-menu-item>
            <el-menu-item index="4" v-show="status == 'authenticated'" @click="diamoneyTransfer = true">
                <strong @click="diamoneyTransfer = true">moneyTransfer</strong>
                <el-dialog v-model="diamoneyTransfer" title="Money Transfer">
                    <el-form :model="form">
                        <el-form-item label="toAddress" :label-width="formLabelWidth">
                            <el-input v-model="transfermoney.toAddress" autocomplete="off" />
                        </el-form-item>
                        <el-form-item label="Amount" :label-width="formLabelWidth">
                            <el-input v-model="transfermoney.amount" autocomplete="off" />
                        </el-form-item>
                    </el-form>
                    <template #footer>
                        <span class="dialog-footer">
                            <el-button @click="diamoneyTransfer = false">Cancel</el-button>
                            <el-button type="primary" @click="moneyTransfer(transfermoney)">Transfer</el-button>
                        </span>
                    </template>
                </el-dialog>
            </el-menu-item>
            <el-menu-item index="5" v-show="status == 'authenticated'" @click="houseBalanceOf">
                <strong> houseBalanceOf </strong>
            </el-menu-item>
            <el-menu-item index="6" v-show="status == 'authenticated'" @click="checkContractExist">
                <strong> checkContract </strong>
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
                        <el-table-column prop="tokenId" label="TokenId" width="100" />
                        <el-table-column prop="owner" label="House owner" width="300" />
                        <el-table-column prop="price" label="Price" sortable />
                        <el-table-column prop="sell" label="On sale" :filters="[
                            { text: 'On sale', value: true },
                            { text: 'Not On sale', value: false },
                        ]" :filter-method="filterHandler" />
                        <el-table-column label="Buy">
                            <template v-slot="{ row }">
                                <!-- !row.sell && owner != userAddress -->
                                <ElButton :disabled="!row.sell || !(row.owner - userAddress)" type="primary"
                                    @click="buy_house(row.tokenId)">Buy</ElButton>
                            </template>
                        </el-table-column>
                        <el-table-column label="Info">
                            <template v-slot="{ row }">
                                <!-- :disable="!(row.tokenURI || row.tokenURI == '')" -->
                                <ElButton type="primary" @click="get_house_detailed(row.tokenId), dialogHouseDetail = True">
                                    Info
                                </ElButton>
                            </template>
                        </el-table-column>

                    </el-table>
                    <el-dialog v-model="dialogHouseDetail" title="House detail" :width="1200">
                        <slot name="-">
                            <el-row>
                                <el-col :span="12">
                                    <el-image :src="house_detail.image" fit="contain" alt="Image"></el-image>
                                </el-col>
                                <el-col :span="12">
                                    <el-form :model="form">
                                        <el-form-item label="Address : " :label-width="formLabelWidth">
                                            {{ house_detail.address }}
                                        </el-form-item>
                                    </el-form>
                                    <el-form :model="form">
                                        <el-form-item label="Built date : " :label-width="formLabelWidth">
                                            {{ house_detail.built_date }}
                                        </el-form-item>
                                    </el-form>
                                    <el-form :model="form">
                                        <el-form-item label="Category : " :label-width="formLabelWidth">
                                            {{ house_detail.category }}
                                        </el-form-item>
                                    </el-form>
                                    <el-form :model="form">
                                        <el-form-item label="Story : " :label-width="formLabelWidth">
                                            {{ house_detail.story }}
                                        </el-form-item>
                                    </el-form>
                                    <el-form :model="form">
                                        <el-form-item label="Size : " :label-width="formLabelWidth">
                                            {{ house_detail.size }}
                                        </el-form-item>
                                    </el-form>
                                    <el-form :model="form">
                                        <el-form-item label="Description : " :label-width="formLabelWidth">
                                            {{ house_detail.description }}
                                        </el-form-item>
                                    </el-form>
                                </el-col>
                            </el-row>
                        </slot>
                        <template #footer>
                            <span class="dialog-footer">
                                <el-button @click="dialogHouseDetail = false">Close</el-button>
                            </span>
                        </template>
                    </el-dialog>
                </ElContainer>
                <div>
                    <ul>
                        <li v-for="item in jsonData" :key="item.id">{{ item.name }}</li>
                    </ul>
                </div>
                <ElContainer v-show="activeIndex == '1'">
                    <el-table :data="houseInfo">
                        <el-table-column prop="tokenId" label="TokenId" width="100" />
                        <el-table-column prop="owner" label="House owner" width="300" />
                        <el-table-column prop="price" label="Price" sortable />
                        <el-table-column prop="sell" label="On sale" :filters="[
                            { text: 'On sale', value: true },
                            { text: 'Not On sale', value: false },
                        ]" :filter-method="filterHandler" />
                        <el-table-column label="Modify">
                            <template v-slot="{ row }">
                                <ElButton type="primary" @click="showModifyDialog(row)" :icon="Edit" />
                            </template>
                        </el-table-column>
                        <el-table-column label="Delete">
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
// import console from 'console';
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
let dialogHouseDetail = ref(false)
let diamoneyTransfer = ref(false)
let modifyForm = reactive({
    tokenId: '',
    price: '',
    sell: '',
    URI: ''
})

let addForm = reactive({
    address: "",
    token_id: "",
    price: "",
    URI: ""
})

let transfermoney = reactive({
    toAddress: "",
    amount: "",
})

let house_detail = reactive({
    address: "",
    built_date: "",
    category: "",
    story: "",
    size: "",
    description: "",
    image: " "
})

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

const filterHandler = (
    value,
    row,
    column
) => {
    const property = column['property']
    return row[property] === value
}

async function confirmModify() {
    console.log("modify house");
    console.log(modifyForm);
    const contract = Contract();
    await contract.set_sell(modifyForm.tokenId, modifyForm.sell);
    await contract.set_house_price(modifyForm.tokenId, modifyForm.price);
    modifyForm.URI && await contract.setTokenURI(modifyForm.tokenId, modifyForm.URI);
    dialogModifyVisible.value = false;
    ElMessage({ message: 'Modify house ' + modifyForm.tokenId + ' success! ', type: 'success' });
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
        return {
            tokenId,
            owner,
            price,
            sell,
            tokenURI
        };
    }));
    houseInfo.value = all_house;
}

async function get_house_detailed(tokenID) {
    const contract = Contract();
    const axios = require('axios');
    const tokenURI = await contract.tokenURI(tokenID);
    console.log('tokenID: ' + tokenID);
    console.log('tokenURI: ' + tokenURI);
    try {
        const ipfs = await axios.get('https://ipfs.io/ipfs/' + tokenURI)
        Object.assign(house_detail, ipfs.data);
        console.log(house_detail)
        dialogHouseDetail.value = true;
    }
    catch (err) {
        ElMessage({ message: '該房子的URI可能不正確', type: 'error' });
        console.log(err);
    }
}
async function Add_house() {
    const address = userAddress.value;
    const contract = Contract();
    try {
        await contract.mint_house(address, addForm.token_id, addForm.price);
        await contract.setTokenURI(addForm.token_id, addForm.URI);
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
async function moneyBalanceOf() {
    const contract = Contract();
    const balance = await contract.moneyBalanceOf(userAddress.value);
    ElMessage({ message: '您擁有' + balance + '塊', type: 'success' });
}

async function moneyTransfer(transfermoney) {
    const contract = Contract();
    console.log(transfermoney.toAddress, transfermoney.amount)
    await contract.money_transfer(transfermoney.toAddress, transfermoney.amount);
    ElMessage({ message: '成功', type: 'success' });
}

async function houseBalanceOf() {
    const contract = Contract();
    const balance = await contract.houseBalanceOf(userAddress.value);
    ElMessage({ message: '您擁有' + balance + '棟房子', type: 'success' });
}

async function checkContractExist() {
    const provider = Provider();
    provider.getCode('0x40606bE53A4b6084581FAF760D226Be6417CF53f').then((code) => {
        if (code === '0x') {
            console.log('Contract does not exist in the blockchain');
        } else {
            console.log('Contract exists in the blockchain');
        }
    });
}

</script>
<style>
.flex-grow {
    flex-grow: 1;
}
</style>