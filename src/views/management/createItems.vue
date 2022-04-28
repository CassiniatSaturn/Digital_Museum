<template>
  <div class=" w-10/12 mx-auto border border-white rounded-lg mt-12 px-16 py-8 text-white">
    <!-- upload -->
    <div class=" text-xl font-bold pb-8">注册数字藏品NFT</div>
    <a-upload v-model:file-list="fileList" name="avatar" list-type="picture-card" class="upload"
      :show-upload-list="false" @change="handleChange">
      <img v-if="imageUrl" :src="imageUrl" alt="avatar" />
      <div v-else>
        <loading-outlined v-if="loading"></loading-outlined>
        <SvgIcon v-else iconClass="pic" class="w-10 h-10 mx-auto"></SvgIcon>
        <div class="ant-upload-text">上传藏品图片</div>
      </div>
    </a-upload>
    <div class=" w-1/3 mx-auto pt-5">
      <p>名称</p>
      <q-input dark label-color="grey-1" color="primary" label="请输入数字藏品NFT的名称" rounded outlined type="text"
        v-model="itemName" />
    </div>
    <div class="w-1/3 mx-auto pt-4">
      <p>描述</p>
      <q-input dark label-color="grey-1" color="primary" label="请输入数字藏品NFT的描述" rounded outlined type="textarea"
        v-model="description" />
    </div>
    <button @click="createItem" class=" bg-purple-600 mt-14 px-10 py-2  rounded-3xl block mx-auto mb-10">创建</button>
  </div>
</template>

<script setup lang="ts">
import { createMktItem } from "@/service/EthService/mktService"
import { ref, onMounted, reactive, computed, toRefs } from "vue";
import { getFileUrl } from "@/service/ipfsService";
import { PlusOutlined, LoadingOutlined } from "@ant-design/icons-vue";
import * as ipfs_core from "ipfs-core";
import { IPFS } from "ipfs-core-types";

/* create the instance of ipfs */
let ipfs = {} as IPFS;
onMounted(async () => {
  ipfs = await ipfs_core.create();
  const result = await ipfs.add('{"name":"qq","description":"aa","image":"QmWfW5LgBWKftxxJMqaEioKzW5NYXPysn5yfrKmTsWGohc"}')
  console.log(result.path);
})

/* Creates a market item */
const itemName = ref("");
const description = ref("");
const url = ref('')

const createItem = async () => {
  if (!itemName.value || !description.value || !imageUrl.value) return
  const data = JSON.stringify({
    name: itemName.value, description: description.value, image: imageUrl.value
  })
  const result = await ipfs.add(data)
  url.value = getFileUrl(result.path)
  await createMktItem(url.value)
};

/* Upload img to IPFS */
const fileList = ref([]);
const loading = ref<boolean>(false);
let imgHash = ref("");
let imageUrl = ref("");
interface FileItem {
  uid: string;
  name?: string;
  status?: string;
  response?: string;
  url?: string;
  type?: string;
  size: number;
  originFileObj: any;
}

interface FileInfo {
  file: FileItem;
  fileList: FileItem[];
}

const handleChange = (info: FileInfo) => {
  loading.value = true;
  const reader = new FileReader();
  reader.readAsArrayBuffer(info.file.originFileObj);
  reader.onloadend = async () => {
    const buffer = new Buffer(reader.result as ArrayBuffer);
    /* upload to IPFS */
    ipfs.add(buffer).then((result) => {
      imgHash.value = result.path;
      imageUrl.value = getFileUrl(imgHash.value);
      console.log(imgHash.value);
    });
  };
};

</script>

<style>
.upload .ant-upload-select-picture-card {
  margin-bottom: 8px;
  text-align: center;
  background-color: transparent;
  border: 1px solid #d9d9d9;
  border-radius: 20px;
  cursor: pointer;
  width: 25%;
  padding-top: 2rem;
  padding-bottom: 2rem;
}

.upload .ant-upload-text {
  color: #FFFFFF;
  font-size: 0.6rem;
  padding-top: 1rem;
}

.ant-upload-picture-card-wrapper {
  text-align: center;
  display: flex;
  justify-content: center;
}
</style>