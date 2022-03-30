<template>
  <div>
    <div>enc</div>
    <div>
      <button @click="toAesEnc">AES加密</button>
    </div>
    <div>
      请输入publicKey
      <input type="text" v-model="PkAdmin" placeholder="publicKey" />
    </div>
    <div>
      <button @click="toRsaEnc">RSA非对称加密</button>
    </div>
    <div>
      请输入privateKey
      <input type="text" v-model="privateKey" placeholder="privateKey" />
    </div>
    <div>
      <button @click="toRsaDec">RSA非对称解密</button>
    </div>
    <div>
      <button @click="toAesDec">AES对称解密</button>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { fetchFromIpfs } from '@/service/ipfsService';
import CryptoJS from 'crypto-js'
import * as ipfs_core from 'ipfs-core'
import { IPFS } from 'ipfs-core-types/src/';
import Jsencrypt from 'jsencrypt'
import { onMounted, ref } from 'vue'


const raw_file = '数字博物馆以数字化形式对自然遗产和文化遗产的各种信息进行存储和管理，并通过互联网为全世界的用户提 供数字化展示、教育和研究等各种服务，是计算机科学、博物馆学和传播学等多学科融合的信息服务系统。数字博物馆跨越了文物传播、文化教育的时间与空间限制，为开拓了博物馆的发展方向与道路。北京故宫作为第一批全国重点文物保护单位，世界文化遗产，拥有超过186万件文物藏品，78万平方米的占地面积。数字故宫肩负联系传统与未来的使命，充分发挥数字技术对保护、研究、传承弘扬中华优秀传统文化的支撑引领作用，是因时代所需，持续推动信息化基础设施建设、基础数据资源采集、加工、利用，公众数字化服务。'
const Pkdm = '0x03E462A632c42593F42ba57738b642A2272Bc06C'
const hash1 = ref('')
const hash2 = ref('')
let ipfs = {} as IPFS
onMounted(async () => {
  ipfs = await ipfs_core.create()
})

const toAesEnc = async () => {
  /* 原文件AES加密上传至IPFS */
  hash1.value = CryptoJS.AES.encrypt(raw_file, Pkdm).toString()
  console.log('原文件密文', hash1.value);
  const res = await ipfs.add(hash1.value)
  hash2.value = res.path
  console.log('ipfs hash', hash2.value);
  // do something to store the hash,public key to smart contract
  /* ... */
}

let PkAdmin = ref('')
const hash3 = ref('')
const privateKey = ref('')
const toRsaEnc = () => {
  const jsencrypt = new Jsencrypt()
  // const res = jsencrypt.getPublicKeyB64()
  // console.log(res);
  jsencrypt.setPublicKey(PkAdmin.value);
  const result = jsencrypt.encrypt(hash2.value)
  if (result) {
    hash3.value = result
    console.log('hash3,RSA加密的hash', hash3.value);
  }
}

const decHash3 = ref('')
const toRsaDec = () => {
  const jsencrypt = new Jsencrypt()
  jsencrypt.setPrivateKey(privateKey.value)
  const result = jsencrypt.decrypt(hash3.value)
  console.log(result);

  if (result) {
    decHash3.value = result
    console.log('解密hash3的hash2', decHash3.value);
  }
}

const toAesDec = async () => {
  const res = await fetchFromIpfs(decHash3.value) as unknown as string
  const result = CryptoJS.AES.decrypt(res,Pkdm).toString(CryptoJS.enc.Utf8)
  console.log(result);

}











</script>