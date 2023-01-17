%%raw("import './AddFolderModal.css'")

@react.component
let make = (
  ~onFolderChange,
  ~folderValue,
  ~handleFolderSave,
  ~handleClose,
  ~onFileChange,
  ~fileValue,
  ~handleFileSave,
) => {
  <div className="outer-modal">
    <div className="inner-modal">
      <div> {"Create Folder"->React.string} </div>
      <input onChange=onFolderChange value=folderValue />
      <div className="footer">
        <button onClick=handleFolderSave className="save"> {"Save"->React.string} </button>
        <button onClick=handleClose className="cancel"> {"Cancel"->React.string} </button>
      </div>
      <div> {"Create File"->React.string} </div>
      <input onChange=onFileChange value=fileValue />
      <div className="footer">
        <button onClick=handleFileSave className="save"> {"Save"->React.string} </button>
        <button onClick=handleClose className="cancel"> {"Cancel"->React.string} </button>
      </div>
    </div>
  </div>
}
