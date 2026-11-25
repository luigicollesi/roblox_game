--!strict
export type Kind = "street" | "district" | "gate" | "establishment" | "room"
export type Location = {
	id: string, name: string, kind: Kind, assetKey: string,
	parentId: string?, connections: {string},
}
export type Snapshot = { locationId: string, revision: number }
return {}
