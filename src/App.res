// import raw for just importing a css file

type state = {
  rootFolder: Folder.t,
  newFolderValue: string,
  newFileValue: string,
  currentFolderId: int,
  modalFolderId: option<int>,
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
  modalFolderId: None,
}

type actions =
  | FolderInputUpdated(string)
  | FileValueUpdated(string)
  | FolderAdded(int)
  | FileAdded
  | FolderSelected(int)
  | ModalOpened(int)
  | ModalClosed

let reducer = (state, action) => {
  switch action {
  | FolderInputUpdated(value) => {...state, newFolderValue: value}
  | FileValueUpdated(value) => {...state, newFileValue: value}
  | FolderAdded(id) =>
    if state.newFolderValue->Js.String2.trim->Js.String2.length > 0 {
      {
        ...state,
        newFolderValue: "",
        modalFolderId: None,
        rootFolder: Folder.addFolderToRoot(
          state.rootFolder,
          state.currentFolderId,
          state.newFolderValue,
          id,
        ),
      }
    } else {
      state
    }
  | FileAdded =>
    if state.newFileValue->Js.String2.trim->Js.String2.length > 0 {
      {
        ...state,
        newFileValue: "",
        modalFolderId: None,
        rootFolder: Folder.addFileToFolder(
          state.rootFolder,
          state.currentFolderId,
          state.newFileValue,
        ),
      }
    } else {
      state
    }

  | FolderSelected(id) => {...state, currentFolderId: id}
  | ModalOpened(id) => {...state, modalFolderId: Some(id)}
  | ModalClosed => {...state, modalFolderId: None}
  }
}

@react.component @genType
let make = () => {
  let (state, dispatch) = React.useReducer(reducer, initState)
  Js.log(state.rootFolder)
  <div className="App">
    {switch state.modalFolderId {
    | None => <> </>
    | Some(_) =>
      <AddFolderModal
        folderValue=state.newFolderValue
        onFolderChange={e => {
          ReactEvent.Form.target(e)["value"]->FolderInputUpdated->dispatch
        }}
        handleFolderSave={_ => Js.Math.random_int(1, 100000)->FolderAdded->dispatch}
        handleClose={_ => dispatch(ModalClosed)}
        fileValue=state.newFileValue
        onFileChange={e => {
          ReactEvent.Form.target(e)["value"]->FileValueUpdated->dispatch
        }}
        handleFileSave={_ => dispatch(FileAdded)}
      />
    }}
    <Folder.Component
      onDoubleClick={id => id->ModalOpened->dispatch}
      recLevel=1
      currentFolder={state.rootFolder}
      handleClick={id => id->FolderSelected->dispatch}
    />
  </div>
}
