(function () {
    var activeElement = document.activeElement;

    var selectionStart = activeElement.selectionStart;
    var selectionEnd = activeElement.selectionEnd;

    var prefix = activeElement.value.substring(0, selectionStart);
    var suffix = activeElement.value.substring(selectionEnd,
                                               activeElement.value.length);
    var selectedText = activeElement.value.substring(selectionStart,
                                                     selectionEnd);

    var resultText = selectedText;
    resultText = resultText.replace(/,/g, " OR ");

    activeElement.value = prefix + resultText + suffix;
})();

