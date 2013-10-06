/*
* (utf-8)
* äöü
*/

var string = "<hello></hello>";
var html = string.replace(/<\/?[^>]+>/gi, '');

if (66.66 > 0) {
    alert(".äöü");
}

if (77 < 88) {
    alert("polska ć,");
}
if (88 < 99) {
    alert("deutsch äöü,");
}
window.echo('deutsch äöü,');
console.log("hello");

echo("äöüßpolska ć,");
