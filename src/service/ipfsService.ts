import axios,{AxiosResponse,AxiosRequestConfig}  from "axios";

const baseURL = 'https://ipfs.io/ipfs'
const ipfsAxios = axios.create({
  baseURL:baseURL,
})

interface iRet<T = any> {
  status: number
  data: T
}

export default <T = any>(config: AxiosRequestConfig) => {
  return (ipfsAxios({
    ...config,
    headers: {
      ...config.headers,
    },
  }) as unknown) as Promise<iRet>
}

export function fetchFromIpfs(hash:string){
  return ipfsAxios({
    url: '/'+hash,
    method: 'get',
  })
}
export function getImgUrl(hash:string){
  return baseURL+'/'+hash
}

