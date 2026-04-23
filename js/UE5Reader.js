// not really an UE5 reader just yet, rather a stub, reads supraworld entries
// joric, 2026

class UESaveObject {
  constructor(binstr) {
    const dataview = new DataView(binstr, binstr.byteOffset, binstr.byteLength);
    const strview = new TextDecoder("latin1").decode(dataview);
    const prefix = '\0PersistentLevel.';
    const regex = new RegExp(prefix, 'gi');
    
    this.Properties = [];
    this.Properties.push({ name: "ThingsToRemove", value: { value: [] } });
    const o = this.Properties[0].value.value;
    
    let match;
    while ((match = regex.exec(strview))) {
      const start = match.index + prefix.length;
      const len = dataview.getInt32(match.index - 3, true) - prefix.length + 1;
      o.push(strview.slice(start, start + len));
    }
  }
}

if (typeof require !== 'undefined' && require.main === module) {
  for (fname of [
    //"C:\\Users\\user\\AppData\\Local\\Supraworld\\Saved\\SaveGames\\Supraworld\\6\\SaveGame.sav"
    "SaveGame.sav"
  ])
  require('fs').readFile(fname, (err, buf) => {
    if (err) {
      console.log(err);
    } else {
      let loadedSave = new UESaveObject(buf.buffer);
      let s = JSON.stringify(loadedSave,null,2);
      require('fs').writeFileSync('save.json', s);
      console.log(s);
    }
  })
}
