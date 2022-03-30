<template>
  <div :class="myClass.header">
    <svg-icon iconClass="like" class="w-10 h-10 text-blue-600" @clickSvg="handleClick" />
    <div>
      <p>展品名称</p>
      <input type="text" v-model="cName" />
    </div>
    <div>
      <p>作者</p>
      <input type="text" v-model="author" />
    </div>
    <div>
      <p>描述</p>
      <input type="text" v-model="description" />
    </div>
    <!-- upload -->
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
    <div>
      <p>朝代</p>
      <input type="text" v-model="dynasty" />
    </div>
    <div>
      <p>分類</p>
      <q-select
        :modelValue="displayedValue"
        :options="typeList"
        @update:modelValue="type = typeList.indexOf(displayedValue)"
      />
    </div>
    <button @click="createNewCollection">创建</button>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive, computed, toRefs } from "vue";
import { getCollections, createCollection } from "@/service/EthService/museumService";
import { fetchFromIpfs, getFileUrl } from "@/service/ipfsService";
import { Collection } from "@/types";
import { Upload } from "ant-design-vue";
import { message } from "ant-design-vue";
import { PlusOutlined, LoadingOutlined } from "@ant-design/icons-vue";
import * as ipfs_core from "ipfs-core";
import { IPFS } from "ipfs-core-types";
import classes from "@/assets/css/style.module.css"

const myClass = ref(classes)

/* create the instance of ipfs */
let ipfs = {} as IPFS;
onMounted(async()=>{
  ipfs = await ipfs_core.create();
})

/* create a collection */
const cName = ref("");
const author = ref("");
const description = ref("");
const dynasty = ref("");
const typeList = ["jewelry", "painting", "pottery"];
const displayedValue = ref(typeList[0]);
const type = ref(0);
let desHash = ref("");

const createNewCollection = async () => {
  /* upload the description to IPFS */
  ipfs
    .add(description.value)
    .then((result) => {
      desHash.value = result.path;
    })
    .then(async () => {
      /* uoload to Ethereum */
      const meta = {date:new Date().getTime(),recorder:'zhangsan',id:'01',level:'1'};
      const metaJSON = JSON.stringify(meta)
      const result = await ipfs.add(metaJSON)
      console.log(result);
      
      await createCollection(
        cName.value,
        author.value,
        desHash.value,
        imgHash.value,
        dynasty.value,
        type.value,
        result.path
      );
    });
  await fetchCollections();
};

/* fetch the collection list */
let state = reactive({ collectionList: [] as Collection[] });
const fetchCollections = async () => {
  state.collectionList = await getCollections();
  console.log(state.collectionList);
};

/* Upload img to IPFS */
const fileList = ref([]);
const loading = ref<boolean>(false);
let imgHash = ref("");
let imageUrl = ref<string>("");
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

const handleClick = ()=>{
  console.log(1);
}
</script>

<style scoped>
avatar-uploader > .ant-upload {
  width: 128px;
  height: 128px;
}
.ant-upload-select-picture-card i {
  font-size: 32px;
  color: #999;
}

.ant-upload-select-picture-card .ant-upload-text {
  margin-top: 8px;
  color: #666;
}
</style>