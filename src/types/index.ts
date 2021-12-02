/* agree with the Collection Type in .sol file */
export interface Collection{
  id:number
  cName:string
  author:string
  detailHash:string
  imgHash:string
  dynasty:string
  genre:Category
}
export enum Category {
  jewelry,
  painting,
  pottery
}