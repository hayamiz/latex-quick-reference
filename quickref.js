
var last_query = "";
var last_subquery = "";

function switch_loading(arg){
    if (arg){
        $('#loading')[0].style.display = "inline";
    }else{
        $('#loading')[0].style.display = "none";
    }
}

function do_search(){
    var query = $('input#latex-query')[0].value;
    var subquery = $('input#latex-subquery')[0].value;

    if (query == last_query && subquery == last_subquery){
        return;
    }

    last_query = query;
    last_subquery = subquery;

    query = encodeURIComponent(query);
    subquery = encodeURIComponent(subquery);

    switch_loading(true);
    $('#entries').load("./engine.rb",
                       {"mode": "search", "query": query, "subquery": subquery},
                       function(){
                           switch_loading(false);
                       });
}

function watchChange(elem, interval, func){
    var last_val = elem.value;
    var timer = setInterval(function()
                            {
                                if (last_val != elem.value){
                                    last_val = elem.value;
                                    func(elem);
                                }
                            }, interval);
    if (elem["quick_watch_change"]){
        clearInterval(elem["quick_watch_change"]["timer"]);
    }
    elem["quick_watch_change"] = {"timer": timer};
}
