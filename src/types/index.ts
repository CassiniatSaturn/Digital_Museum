/* agree with the Collection Type in .sol file */
export interface Collection{
  cName:string
  author:string
  detailHash:string
  imgHash:string
  dynasty:string
  type:Category
}
export enum Category {
  jewelry,
  painting,
  pottery
}