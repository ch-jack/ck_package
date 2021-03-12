var type = "normal";
var disabled = false;
var disabledFunction = null;
var Config = new Object();
Config.closeKeys = [113, 27, 90, 8];

window.addEventListener("message", function (event) {
    if (event.data.action == "display") {
        type = event.data.type
        disabled = false;

        if (type === "normal") {
            // $(".info-div").show();
            $(".info-div").hide();
        } else if (type === "show") {
            $(".info-div").show();
        }

        $(".ui").fadeIn();
    } else if (event.data.action == "hide") {
        $(".ui").fadeOut();
        $(".item").remove();
        $("#otherInventory").html("<div id=\"noSecondInventoryMessage\"></div>");
        $("#noSecondInventoryMessage").html("");
    } else if (event.data.action == "setItems") {
        inventorySetup(event.data.itemList);

        $('.item').draggable({
            helper: 'clone',
            appendTo: 'body',
            zIndex: 99999,
            revert: 'invalid',
            start: function (event, ui) {
                if (disabled) {
                    return false;
                }

				$(this).css('background', 'rgba(144,238,144, 0.5)');
                // $(this).css('display', 'none');
				// $(this).fadeOut();
                itemData = $(this).data("item");
                itemInventory = $(this).data("inventory");

                if (itemInventory == "second" || itemData.bind == 1) {
                    $("#drop").addClass("disabled");
                    $("#give").addClass("disabled");
                }

                if (itemInventory == "second" || !itemData.usable) {
                    $("#use").addClass("disabled");
                }
            },
            stop: function () {
                itemData = $(this).data("item");

                if (itemData !== undefined && itemData.name !== undefined) {
					$(this).css('background', 'rgba(0, 0, 0, 0.0)');
                    // $(this).css('display', 'display');
					// $(this).fadeIn();
                    $("#drop").removeClass("disabled");
                    $("#use").removeClass("disabled");
                    $("#give").removeClass("disabled");
                }
            }
        });
    } else if (event.data.action == "setSecondInventoryItems") {
        secondInventorySetup(event.data.itemList);
    } else if (event.data.action == "setShopInventoryItems") {
        shopInventorySetup(event.data.itemList)
    } else if (event.data.action == "setInfoText") {
        $(".info-div").html(event.data.text);
    }
});

function closeInventory() {
    $.post("http://ck_package/NUIFocusOff", JSON.stringify({}));
}

function inventorySetup(items) {
    $("#playerInventory").html("");
    $.each(items, function (index, item) {
        count = setCount(item);

        // $("#playerInventory").append('<div class="slot"><div id="item-' + index + '" class="item" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
        $("#playerInventory").append('<div class="slot"><div id="item-' + index + '" class="item"> <img src="img/items/' + item.name + '.png" onerror="this.src=\'img/items/box.png\'" class="items">' +
            '<div class="item-count">' + count + '</div> <div class="item-name">' + item.label + '</div> </div ><div class="item-name-bg"></div></div>');
        $('#item-' + index).data('item', item);
        $('#item-' + index).data('inventory', "main");
    });
}

function secondInventorySetup(items) {
    $("#otherInventory").html("");
    $.each(items, function (index, item) {
        count = setCount(item);

        // $("#otherInventory").append('<div class="slot"><div id="itemOther-' + index + '" class="item" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
		$("#otherInventory").append('<div class="slot"><div id="itemOther-' + index + '" class="item"> <img src="img/items/' + item.name + '.png" onerror="this.src=\'img/items/box.png\'" class="items">' +

            '<div class="item-count">' + count + '</div> <div class="item-name">' + item.label + '</div> </div ><div class="item-name-bg"></div></div>');
        $('#itemOther-' + index).data('item', item);
        $('#itemOther-' + index).data('inventory', "second");
    });
}

function shopInventorySetup(items) {
    $("#otherInventory").html("");
    $.each(items, function (index, item) {
        //count = setCount(item)
        cost = setCost(item);

        // $("#otherInventory").append('<div class="slot"><div id="itemOther-' + index + '" class="item" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
		$("#otherInventory").append('<div class="slot"><div id="itemOther-' + index + '" class="item"> <img src="img/items/' + item.name + '.png" onerror="this.src=\'img/items/box.png\'" class="items">' +

            '<div class="item-count">' + cost + '</div> <div class="item-name">' + item.label + '</div> </div ><div class="item-name-bg"></div></div>');
        $('#itemOther-' + index).data('item', item);
        $('#itemOther-' + index).data('inventory', "second");
    });
}

function Interval(time) {
    var timer = false;
    this.start = function () {
        if (this.isRunning()) {
            clearInterval(timer);
            timer = false;
        }

        timer = setInterval(function () {
            disabled = false;
        }, time);
    };
    this.stop = function () {
        clearInterval(timer);
        timer = false;
    };
    this.isRunning = function () {
        return timer !== false;
    };
}

function disableInventory(ms) {
    disabled = true;

    if (disabledFunction === null) {
        disabledFunction = new Interval(ms);
        disabledFunction.start();
    } else {
        if (disabledFunction.isRunning()) {
            disabledFunction.stop();
        }

        disabledFunction.start();
    }
}

function setCount(item) {
    count = item.count

    if (item.limit > 0) {
        count = item.count + " / " + item.limit
    }

    if (item.type === "item_weapon") {
        if (count == 0) {
            count = "";
        } else {
            count = '<img src="img/bullet.png" class="ammoIcon"> ' + item.count;
        }
    }

    if (item.type === "item_account" || item.type === "item_money") {
        count = formatMoney(item.count);
    }

    return count;
}

function setCost(item) {
    cost = item.price

    if (item.price == 0){
        cost = "$" + item.price
    }
    if (item.price > 0) {
        cost = "$" + item.price
    }
    return cost;
}

function formatMoney(n, c, d, t) {
    var c = isNaN(c = Math.abs(c)) ? 2 : c,
        d = d == undefined ? "." : d,
        t = t == undefined ? "," : t,
        s = n < 0 ? "-" : "",
        i = String(parseInt(n = Math.abs(Number(n) || 0).toFixed(c))),
        j = (j = i.length) > 3 ? j % 3 : 0;

    return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t);
};

$(document).ready(function () {
    $("#count").focus(function () {
        $(this).val("")
    }).blur(function () {
        if ($(this).val() == "") {
            $(this).val("1")
        }
    });

    $("body").on("keyup", function (key) {
        if (Config.closeKeys.includes(key.which)) {
            closeInventory();
        }
    });

    $('#use').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");

            if (itemData == undefined || itemData.usable == undefined) {
                return;
            }

            itemInventory = ui.draggable.data("inventory");

            if (itemInventory == undefined || itemInventory == "second") {
                return;
            }

            if (itemData.usable) {
                disableInventory(300);
                $.post("http://ck_package/UseItem", JSON.stringify({
                    name: itemData.name,
                    count: parseInt($("#count").val()),
                }));
            }
        }
    });

    $('#give').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");

            if (itemData == undefined || itemData.bind == 1) {
                return;
            }

            itemInventory = ui.draggable.data("inventory");

            if (itemInventory == undefined || itemInventory == "second") {
                return;
            }

            if (itemData.bind) {
                disableInventory(300);
                $.post("http://ck_package/GiveItem", JSON.stringify({
                    name: itemData.name,
                    count: parseInt($("#count").val()),
                }));
            }
        }
    });

    $('#drop').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");

            if (itemData == undefined || itemData.bind == 1) {
                return;
            }

            itemInventory = ui.draggable.data("inventory");

            if (itemInventory == undefined || itemInventory == "second") {
                return;
            }

            if (itemData.bind) {
                disableInventory(300);
                $.post("http://ck_package/DropItem", JSON.stringify({
                    name: itemData.name,
                    count: parseInt($("#count").val())
                }));
            }
        }
    });

    $('#playerInventory').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");
            itemInventory = ui.draggable.data("inventory");

            if (itemInventory === "second") {
                disableInventory(500);
                $.post("http://ck_package/TakeFromOther", JSON.stringify({
                    name: itemData.name,
                    count: parseInt($("#count").val())
                }));
            }
        }
    });

    $('#otherInventory').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");
            itemInventory = ui.draggable.data("inventory");

            if (itemInventory === "main") {
                disableInventory(500);
                $.post("http://ck_package/PutIntoOther", JSON.stringify({
                    name: itemData.name,
                    count: parseInt($("#count").val())
                }));
            }
        }
    });

    $("#count").on("keypress keyup blur", function (event) {
        $(this).val($(this).val().replace(/[^\d].+/, ""));
        if ((event.which < 48 || event.which > 57)) {
            event.preventDefault();
        }
    });
});
