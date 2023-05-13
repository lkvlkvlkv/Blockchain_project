# project

## Project setup
```
npm install vue
npm install ethers@5.7.2
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Target
- 希望東西能動，確保東西都有串起來並正確無誤
- 希望可以用[figma](https://www.figma.com/file/oGl2L1qWewLj6DqxSpIsq7/Vuetify-(Material-Design-Component-Figma-Library-For-Vue.js)-(Community)?type=design&node-id=2-0&t=nH3FMdzlkzaO3xB5-0)來設計前端。

### Explain

#### App.vue

包含前端外觀的所有東西，還有按按鈕該如何傳遞參數給合約

#### contract.js

包含合約的地址和合約的abi，如果換一台電腦跑，記得重新用remix ide編譯合約後，去複製合約的abi和地址
