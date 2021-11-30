<template>
  <div class="bg-purple-300">
    <div>
      <p>作品名稱</p>
      <input type="text" v-model="cName" />
    </div>
    <div>
      <p>作者名稱</p>
      <input type="text" v-model="author" />
    </div>
    <div>
      <p>詳情hash</p>
      <input type="text" v-model="detailHash" />
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
      <p>圖片hash</p>
      <input type="text" v-model="imgHash" />
    </div>
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
    <button @click="createNewCollection">創建</button>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive, computed, toRefs } from "vue";
import { getCollections, createCollection } from "@/service/ethService";
import { fetchFromIpfs, getImgUrl } from "@/service/ipfsService";
import { Collection } from "@/types";
import { Upload } from "ant-design-vue";
import { message } from "ant-design-vue";
import { PlusOutlined, LoadingOutlined } from "@ant-design/icons-vue";
import * as IPFS from "ipfs-core";

/* create a collection */
const cName = ref("");
const author = ref("");
const detailHash = ref("");
const imgHash = ref("");
const dynasty = ref("");
const typeList = ["jewelry", "painting", "pottery"];
const displayedValue = ref(typeList[0]);
const type = ref(0);

const createNewCollection = async () => {
  await createCollection(
    cName.value,
    author.value,
    detailHash.value,
    dynasty.value,
    imgHash.value,
    type.value
  );
  fetchCollections();
};

/* fetch the collection list */
let state = reactive({ collectionList: [] as Collection[] });
const fetchCollections = async () => {
  state.collectionList = await getCollections();
  console.log(state.collectionList);
};
const handleUpdate = (value: any) => {
  console.log(11);

  console.log(value);
};

/* Upload img to IPFS */
const fileList = ref([]);
const loading = ref<boolean>(false);
const imageUrl = ref<string>("");
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
  /* transfer blob to unit8array */
  const reader = new FileReader();
  reader.readAsArrayBuffer(info.file.originFileObj);
  reader.onloadend = async () => {
    const buffer = new Buffer(reader.result as ArrayBuffer);
    /* upload to IPFS */
    const ipfs = await IPFS.create();
    ipfs.add(buffer).then((result)=>{
      console.log(result.path); 
    })
  };
};
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