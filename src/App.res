// import raw for just importing a css file
%%raw("import './App.css'")

type state = {
  rootFolder: Folder.t,
  newFolderValue: string,
  newFileValue: string,
  currentFolderId: int,
}

let initState = {
  rootFolder: {
    id: 0,
    name: "root",
    folders: [],
    files: [],
  },
  newFolderValue: "",
  newFileValue: "",
  currentFolderId: 0,
}

type actions =
  | FolderInputUpdated(string)
  | FileValueUpdated(string)
  | FolderAdded(int)
  | FileAdded
  | FolderSelected(int)

let reducer = (state, action) => {
  switch action {
  | FolderInputUpdated(value) => {...state, newFolderValue: value}
  | FileValueUpdated(value) => {...state, newFileValue: value}
  | FolderAdded(id) => {
      ...state,
      newFolderValue: "",
      rootFolder: Folder.addFolderToRoot(
        state.rootFolder,
        state.currentFolderId,
        state.newFolderValue,
        id,
      ),
    }
  | FileAdded => {...state, newFileValue: ""}
  | FolderSelected(id) => {...state, currentFolderId: id}
  }
}

@react.component @genType
let make = () => {
  let (state, dispatch) = React.useReducer(reducer, initState)
  let folderSelectedString = state.currentFolderId->Belt.Int.toString
  <div className="App">
    <div> {React.string("Folder selected: " ++ folderSelectedString)} </div>
    <div>
      <label> {"New folder name"->React.string} </label>
      <input
        value={state.newFolderValue}
        onChange={e => {
          let updatedValue = ReactEvent.Form.currentTarget(e)["value"]
          updatedValue->FolderInputUpdated->dispatch
        }}
      />
      <button type_="button" onClick={_ => Js.Math.random_int(0, 100000)->FolderAdded->dispatch}>
        {"Add Folder"->React.string}
      </button>
    </div>
    /* {state.rootFolder.folders */
    /* ->Belt.Array.map(folder => <div> {folder.name->React.string} </div>) */
    /* ->React.array} */
    <Folder.Component
      recLevel=1 currentFolder={state.rootFolder} handleClick={id => id->FolderSelected->dispatch}
    />
  </div>
}
