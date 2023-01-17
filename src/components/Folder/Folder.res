%%raw("import './Folder.css'")

type rec t = {
  id: int,
  name: string,
  mutable folders: array<t>,
  mutable files: array<string>,
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
  originalRootFolder: t,
  targetFolderId: int,
  newFolders: array<t>,
): t => {
  let rootFolder = Interop.structuredClone(originalRootFolder)
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

let addFileToFolder = (originalRootFolder: t, targetId: int, targetContent: string): t => {
  let rootFolder = Interop.structuredClone(originalRootFolder)
  let targetFolder = findFolderById(rootFolder, targetId)
  let _ = targetFolder->Belt.Option.map(t => {
    t.files = t.files->Js.Array2.concat([targetContent])
  })
  rootFolder
}

type componentProps = {
  onDoubleClick: int => unit,
  currentFolder: t,
  handleClick: int => unit,
  recLevel: int,
}

module rec Component: {
  let make: componentProps => Jsx.element
} = {
  let make = ({onDoubleClick, currentFolder, handleClick, recLevel}) => {
    let (isOpen, setOpen) = React.useState(_ => false)
    <div onDoubleClick={_ => onDoubleClick(currentFolder.id)}>
      <div
        role="button"
        onClick={_ => {
          setOpen(prev => !prev)
          handleClick(currentFolder.id)
        }}>
        <div
          style={ReactDOM.Style.make(~paddingLeft=(recLevel * 32)->Belt.Int.toString ++ "px", ())}
          className="flex-folder-name-inner folder-name">
          {currentFolder.name->React.string}
          <span
            style={ReactDOM.Style.make(
              ~marginLeft="6px",
              ~transform=switch isOpen {
              | true => "rotate(90deg)"
              | false => ""
              },
              (),
            )}>
            {">"->React.string}
          </span>
        </div>
      </div>
      {switch isOpen {
      | true =>
        <>
          <div
            style={ReactDOM.Style.make(
              ~paddingLeft=(recLevel * 32)->Belt.Int.toString ++ "px",
              (),
            )}>
            {currentFolder.files
            ->Belt.Array.map(file => {
              <div key=file style={ReactDOM.Style.make(~background="white", ~padding="0", ())}>
                {React.string(file)}
              </div>
            })
            ->React.array}
          </div>
          {currentFolder.folders
          ->Belt.Array.map(folder =>
            <Component
              onDoubleClick
              key={folder.id->Belt.Int.toString}
              recLevel={recLevel + 1}
              handleClick
              currentFolder=folder
            />
          )
          ->React.array}
        </>
      | false => <> </>
      }}
    </div>
  }
}
