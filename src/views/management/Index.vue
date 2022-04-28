<template>
  <div class=" border border-white rounded-lg w-10/12 mx-auto mt-24 text-white px-16">
    <div class=" text-2xl font-bold my-12">展示信息</div>
    <!-- upload -->

      <a-upload-dragger class="uploadragger" v-model:file-list="state.fileList" name="file" :maxCount="1" :multiple="false"
        @change="handleChange">
        <p class="ant-upload-drag-icon">
          <inbox-outlined :style="{color:'white'}"></inbox-outlined>
        </p>
        <p class="ant-upload-text">点击上传</p>
        <p class="ant-upload-hint">
          支持图片、视频等格式
        </p>
      </a-upload-dragger>


    <div class=" flex mt-8 justify-between">
      <div class=" w-96">
        <p>展品名称</p>
        <q-input dark label-color="grey-1" color="primary" label="请输入展品名称" rounded outlined type="text"
          v-model="cName" />
      </div>
      <div class="w-96">
        <p>作者</p>
        <q-input dark label-color="grey-1" color="gray-1" label="请输入作者" rounded outlined type="text" v-model="author" />
      </div>
    </div>

    <div class=" flex mt-8 justify-between">
      <div class=" w-96">
        <p>朝代</p>
        <q-input dark label-color="grey-1" color="gray-1" label="请输入朝代" rounded outlined type="text"
          v-model="dynasty" />
      </div>
      <div class=" w-96">
        <p>藏品类别</p>
        <q-select dark rounded outlined v-model="displayedValue" :options="typeList" @update:modelValue="modilfyType" />
      </div>
    </div>

    <div class=" mt-8">
      <p>描述</p>
      <q-input type="textarea" dark label-color="grey-1" color="gray-1" label="请输入描述" rounded outlined
        v-model="description" />
    </div>

    <div class=" text-2xl font-bold my-12">管理元数据</div>
    <div class=" flex mt-8 justify-between">
      <div class=" w-96">
        <p>藏品编号</p>
        <q-input dark label-color="grey-1" color="gray-1" label="请输入藏品编号" rounded outlined type="text" v-model="cid" />
      </div>
      <div class=" w-96">
        <p>数据编目日期</p>
        <q-input dark label-color="grey-1" color="gray-1" label="请输入数据编目日期" rounded outlined type="text"
          v-model="recordDate" />
      </div>
    </div>

    <div class=" flex mt-8 justify-between">
      <div class=" w-96">
        <p>数据编目人员</p>
        <q-input dark label-color="grey-1" color="gray-1" label="请输入数据编目人员" rounded outlined type="text"
          v-model="recorder" />
      </div>
      <div class=" w-96">
        <p>藏品级别</p>
        <q-input dark label-color="grey-1" color="gray-1" label="请输入藏品级别" rounded outlined type="text"
          v-model="level" />
      </div>
    </div>

    <button class=" bg-purple-600 mt-14 px-10 py-2  rounded-3xl block mx-auto mb-10"
      @click="createNewCollection">上传</button>
  </div>
</template>

<script setup lang="ts">
import { InboxOutlined } from '@ant-design/icons-vue';
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


/* create the instance of ipfs */
let ipfs = {} as IPFS;
onMounted(async () => {
  ipfs = await ipfs_core.create();
})

/* create a collection */
const typeList = ["珠宝首饰", "绘画", "陶瓷"];
const cName = ref("");
const author = ref("");
const description = ref("");
const dynasty = ref("");
const displayedValue = ref(typeList[0]);
const type = ref(0);
const cid = ref('')
const recordDate = ref('')
const recorder = ref('')
const level = ref('')
const desHash = ref("");

const createNewCollection = async () => {
  if (cName.value && author.value && description.value && dynasty.value && type.value) {
    /* upload the description to IPFS */
    ipfs
      .add(description.value)
      .then((result) => {
        desHash.value = result.path;
      })
      .then(async () => {
        /* uoload to Ethereum */
        const meta = { date: recordDate.value, recorder: recorder.value, id: cid.value, level: level.value };
        const metaJSON = JSON.stringify(meta)
        const result = await ipfs.add(metaJSON)

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
  }
  else return
};

/* Upload img to IPFS */
const state = reactive({ fileList: [] as FileItem[] })
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
  if (state.fileList.length > 1) state.fileList.pop()
  const reader = new FileReader();
  reader.readAsArrayBuffer(info.file.originFileObj);
  reader.onloadend = async () => {
    const buffer = new Buffer(reader.result as ArrayBuffer);
    /* upload to IPFS */
    ipfs.add(buffer).then((result) => {
      imgHash.value = result.path;
      imageUrl.value = getFileUrl(imgHash.value);
      state.fileList[0].name = imgHash.value
      state.fileList[0].url = imageUrl.value
      state.fileList[0].status = 'done'
      console.log(imgHash.value);
    });
  };
};

const modilfyType = () => {
  type.value = typeList.indexOf(displayedValue.value)
  console.log(type.value);
}
</script>

<style lang="scss">
.uploadragger > .ant-upload-drag {
  color: white;
  text-align: center;
  background: transparent;
  border: 1px solid #FFFFFF;
  border-radius: 20px;
  cursor: pointer;
}

.ant-upload.ant-upload-drag p.ant-upload-text{
  color: #FFFFFF;
}
.ant-upload.ant-upload-drag p.ant-upload-hint {
  color: #FFFFFF;
}
</style>