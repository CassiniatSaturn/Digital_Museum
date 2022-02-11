<template>
  <div>
    <!-- upload -->
    <div>Creare New Item</div>
    <div>Upload image of Item</div>
    <a-upload
      v-model:file-list="fileList"
      name="avatar"
      list-type="picture-card"
      class="avatar-uploader"
      :show-upload-list="false"
      @change="handleChange"
    >
      <img v-if="imageUrl" :src="imageUrl" alt="avatar" />
      <div v-else>
        <loading-outlined v-if="loading"></loading-outlined>
        <plus-outlined v-else></plus-outlined>
        <div class="ant-upload-text">Upload</div>
      </div>
    </a-upload>
    <div>Name</div>
    <input type="text" placeholder="please enter the name" v-model="itemName" />
    <div>Price</div>
    <input type="text" placeholder="please enter the price" v-model="price" />
    <div>Description</div>
    <input type="text" placeholder="please enter the ipfs hash" v-model="description" />
    <button @click="createItem">创建</button>
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
onMounted(async()=>{
  ipfs = await ipfs_core.create();
})

/* Creates a market item */
const itemName = ref("");
const description = ref("");
const price = ref(0)
const url = ref('')

const createItem = async () => {
  if (!itemName.value || !description.value || !price.value || !imageUrl.value) return
  /* first, upload to IPFS */
  const data = JSON.stringify({
    name: itemName.value, description: description.value, image: imageUrl.value
  })
  console.log(data);

  ipfs
    .add(data)
    .then((result) => {
      const dataHash = result.path;
      url.value = getFileUrl(dataHash)
    })
    .then(async () => {
      /* upload to Ethereum */
      await createMktItem(price.value, url.value)
    });

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