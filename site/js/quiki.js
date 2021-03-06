
function insertAtCursor(Id, myValue) {
    var myField = document.getElementById(Id);
    //IE support
    if (document.selection) {
        myField.focus();
        sel = document.selection.createRange();
        sel.text = myValue;
    }
    //MOZILLA/NETSCAPE support
    else if (myField.selectionStart || myField.selectionStart == '0') {
        var startPos = myField.selectionStart;
        var endPos = myField.selectionEnd;
        myField.value = myField.value.substring(0, startPos)
            + myValue
            + myField.value.substring(endPos, myField.value.length);
    } else {
        myField.value += myValue;
    }
}



function revealModal(divID)
{
    window.onscroll = function () {
        document.getElementById(divID).style.top = document.body.scrollTop;
    };
    document.getElementById(divID).style.display = "block";
    document.getElementById(divID).style.top = document.body.scrollTop;
}

function hideModal(divID)
{
    document.getElementById(divID).style.display = "none";
}

function updateField(filefield, number) {
    var name = document.getElementById( "name" + number );
    if (! name.value && filefield.value) {
        var temp = filefield.value;
        temp = temp.replace(/.*[\\\/]/, "");
        name.value = temp;
    }
}

