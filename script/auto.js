var a = ["Is ", "every ", "person ", "here ", "a ", "mental ", "case ", "?"];
var i, j, p, e;
i = j = p = 0;
function r() {
    "use strict";
    var s = e.textContent || e.innerText;
    s = s.substr(0,p) + a[i].charAt(j);
    p += 1;
    j += 1;
    if (j >= a[i].length) {
        j = 0;
        i += 1;
        p += 1;
        if (i >= a.length) {
            i = p = 0;
        }
    }
    e.textContent = e.innerText = s;
    setTimeout(r, p ? j ? 50 : 100 : 2000);
}
