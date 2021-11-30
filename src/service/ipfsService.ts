import axios, { AxiosResponse, AxiosRequestConfig } from "axios";
import * as IPFS from 'ipfs-core'

// connect to the default API address http://localhost:5001
/*  host?: string;
    port?: number;
    protocol?: string;
    headers?: Headers | Record<string, string>;
    timeout?: number | string;
    apiPath?: string;
    url?: URL | string | Multiaddr;
    ipld?: Partial<IPLDOptions>;
    agent?: HttpAgent | HttpsAgent; */
// const url = new URL('/ipfsApi')
// const baseIpfs = create({url:'/ipfsApi'})
const baseURL = 'https://ipfs.io/ipfs'
const ipfsAxios = axios.create({
  baseURL: baseURL,
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

export function fetchFromIpfs(hash: string) {
  return ipfsAxios({
    url: '/' + hash,
    method: 'get',
  })
}
export function getImgUrl(hash: string) {
  return baseURL + '/' + hash
}