;(function () {
  'use strict'

  var resultNode = $('#result')[0];
  var templateDemoNode = $('#tmpl-demo')[0];
  var dataNode = getDataNode();
  var mintableOption = $('#isMintable')[0];
  var cappedOption = $('#isCapped')[0];
  var changeCapAmountOption = $('#isCappingChangeable')[0];
  var burnableOption = $('#isBurnable')[0];
  var burnableByEveryoneOption = $('#isBurnableByEveryone')[0];
  
 function getDataNode() {
    return {
      "year": new Date().getFullYear(),
      "companyName": $('#companyName')[0].value,
      "userEmail": $('#userEmail')[0].value,
      "tokenName": $('#tokenName')[0].value,
      "tokenTicket": $('#tokenTicket')[0].value,
      "decimalPlaces": $('#decimalPlaces')[0].value,
      "initialSupply": $('#initialSupply')[0].value,
      "isPausable": $('#isPausable')[0].checked,
      "isMintable": $('#isMintable')[0].checked,
      "isCapped": $('#isCapped')[0].checked,
      "capAmount": $('#capAmount')[0].value,
      "isCappingChangeable": $('#isCappingChangeable')[0].checked,
      "isBurnable": $('#isBurnable')[0].checked,
      "isBurnableByEveryone": $('#isBurnableByEveryone')[0].checked,
      "includeApproveAndCall": $('#includeApproveAndCall')[0].checked,
      "includeTransferAndCall": $('#includeTransferAndCall')[0].checked
    };
  }

  function handleSubCheckboxes() {
    mintableOption.onclick = function() {
      if (!mintableOption.checked) {
        cappedOption.checked = false;
        changeCapAmountOption.checked = false;
      }
    }

    cappedOption.onclick = function() {
      if (cappedOption.checked) {
        mintableOption.checked = true;
      } else {
        changeCapAmountOption.checked = false;
      }
    }

    changeCapAmountOption.onclick = function() {
      if (changeCapAmountOption.checked) {
        mintableOption.checked = true;
        cappedOption.checked = true;
      }
    }

    burnableOption.onclick = function() {
      if (!burnableOption.checked) {
        burnableByEveryoneOption.checked = false;
      }
    }

    burnableByEveryoneOption.onclick = function() {
      if (burnableByEveryoneOption.checked) {
        burnableOption.checked = true;
      }
    }
  }

  function renderError (title, error) {
    resultNode.innerHTML = tmpl(
      'tmpl-error',
      {title: title, error: error}
    )
  }

  function render (event) {
    
    if(Form.checkValidity()){
      if (event) {
        event.preventDefault();
        event.stopPropagation();
      }
      var data
      try {
        data = getDataNode();
      } catch (e) {
        renderError('JSON parsing failed', e)
        return
      }
      try {
        resultNode.innerHTML = tmpl(
          templateDemoNode.innerHTML,
          data
        );
        $('.copy-to-clipboard').on("click", function() {
          var contract = $('.result')[0];
          var range = document.createRange();  
          range.selectNode(contract);  
          window.getSelection().removeAllRanges();
          window.getSelection().addRange(range); 
          document.execCommand('copy');
      
          clearSelection();
        });
        $('.title')[0].hidden = false;
      } catch (e) {
        renderError('Template rendering failed', e)
      }
    }
  }

  function empty (node) {
    while (node.lastChild) {
      node.removeChild(node.lastChild)
    }
  }

  function init (event) {
    if (event) {
      event.preventDefault()
    }
    empty(resultNode);

    handleSubCheckboxes();

    $('#Form')[0].addEventListener('submit', render)
    
    var syncOnElementEventList = ['#isPausable', '#isMintable', '#isCapped', '#companyName', '#userEmail', '#tokenName', '#tokenTicket', '#decimalPlaces', '#initialSupply', '#isCappingChangeable' ];
    $.each(syncOnElementEventList, function(index, item){
      $(item)[0].addEventListener('change', syncData) 
    });
  }

  function syncData(event) {
    var capAmount = $('#capAmount')[0];
    capAmount.required = $('#isCapped')[0].checked;
    capAmount.hidden = !capAmount.required;

    if (event) {
      event.preventDefault()
    }
    dataNode = getDataNode();
    //render (event);
  }

  function clearSelection() {
    if ( document.selection ) {
        document.selection.empty();
    } else if ( window.getSelection ) {
        window.getSelection().removeAllRanges();
    }
  }

  init()
}())
