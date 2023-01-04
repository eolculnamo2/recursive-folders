type rec t = {
  id: int,
  name: string,
  mutable folders: array<t>,
  files: array<string>,
}

let createNewFolder = (name: string, id: int) => {
  id,
  name,
  folders: [],
  files: [],
}

let rec findFolderById = (currentFolder: t, id: int): option<t> => {
  if currentFolder.id == id {
    Some(currentFolder)
  } else if currentFolder.folders->Belt.Array.length == 0 {
    None
  } else {
    currentFolder.folders
    ->Belt.Array.map(folder => {
      findFolderById(folder, id)
    })
    ->Js.Array2.find(folder => folder->Belt.Option.isSome)
    ->Belt.Option.getWithDefault(None)
  }
}

let replaceFoldersForTargetFolder = (
  rootFolder: t,
  targetFolderId: int,
  newFolders: array<t>,
): t => {
  let targetFolder = findFolderById(rootFolder, targetFolderId)
  let _ = targetFolder->Belt.Option.map(folder => folder.folders = newFolders)
  rootFolder
}

let addFolderToRoot = (rootFolder: t, targetFolderId: int, name: string, id: int): t => {
  let targetFolder = findFolderById(rootFolder, targetFolderId)
  let updatedTargetFolder = targetFolder->Belt.Option.map(folder => {
    folder.folders->Js.Array2.concat([createNewFolder(name, id)])
  })
  switch updatedTargetFolder {
  | None => rootFolder
  | Some(newFolders) => replaceFoldersForTargetFolder(rootFolder, targetFolderId, newFolders)
  }
}

module rec Component: {
  let make: {"currentFolder": t, "handleClick": int => unit, "recLevel": int} => React.element
  let makeProps: (
    ~currentFolder: t,
    ~handleClick: int => unit,
    ~recLevel: int,
    ~key: string=?,
    unit,
  ) => {"currentFolder": t, "handleClick": int => unit, "recLevel": int}
} = {
  @react.component
  let make = (~currentFolder, ~handleClick, ~recLevel) => {
    let (isOpen, setOpen) = React.useState(_ => false)
    <div style={ReactDOM.Style.make(~marginLeft=(recLevel * 32)->Belt.Int.toString ++ "px", ())}>
      <div
        role="button"
        onClick={_ => {
          setOpen(prev => !prev)
          handleClick(currentFolder.id)
        }}>
        {currentFolder.name->React.string}
      </div>
      {switch isOpen {
      | true =>
        currentFolder.folders
        ->Belt.Array.map(folder =>
          <Component recLevel={recLevel + 1} handleClick currentFolder=folder />
        )
        ->React.array
      | false => <> </>
      }}
    </div>
  }
}
