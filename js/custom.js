
function menuFix(){
    if($(window).width() < 991){
        vph = $(window).height();
        $('.pwi_nav').css({'height': vph - 100 + 'px'});
    };
}

function homeSliderFix(){
    vph = $(window).height();
    $('.homeSliderHeight').css({'height': vph - 70 + 'px'});
}

jQuery(document).ready(function($) {

    menuFix();
    homeSliderFix();

    $( window ).resize(function() {
        menuFix();
        homeSliderFix();
    });

    $('#screen_slider').flexslider({
        animation: "slide",
        slideshowSpeed: 5000,
        animationSpeed: 1000,
        controlNav: false,
        directionNav: true,
        slideshow: true
    });

    $(window).load(function(){
        $("#header").sticky({ topSpacing: 0 });
    });

    new WOW().init();

    $(".menu_btn").click(function(){
        $("#header").toggleClass("openNav");
        return false;
    });

    jQuery("#btn_icons").click(function(event) {
        if($(this).hasClass('collapsed')){
            $('html, body').animate({
                scrollTop: $("#icons_box").offset().top
            }, 300);
        }
    });

    

    // scrollTop
    $(window).scroll(function(){
        if ($(this).scrollTop() > 200) {
            $('.scrollup').fadeIn();
            $('.right_selection').fadeIn();
        } else {
            $('.scrollup').fadeOut();
            $('.right_selection').fadeOut();
        }
    }); 

    $('.scrollup').click(function(){
        $("html, body").animate({ scrollTop: 0 }, 600);
        return false;
    });

//Smooth Scrolling
$(function() {
    $('.banner_menu li a[href*=#]:not([href=#])').click(function() {
        if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
            var target = $(this.hash);
            target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
            if (target.length) {
                $('html,body').animate({
                  scrollTop: target.offset().top
              }, 1000);
                return false;
            }
        }
    });

    $('a.arrow_bottom[href*=#]:not([href=#])').click(function() {
        if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
            var target = $(this.hash);
            target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
            if (target.length) {
                $('html,body').animate({
                  scrollTop: target.offset().top
              }, 1000);
                return false;
            }
        }
    });
});
//Smooth Scrolling end


// Cache selectors
var lastId,
topMenu = $(".right_selection"),
topMenuHeight = topMenu.outerHeight()+15,
menuItems = topMenu.find("a"),
scrollItems = menuItems.map(function(){
    var item = $($(this).attr("href"));
    if (item.length) { return item; }
});

menuItems.click(function(e){
    var href = $(this).attr("href"),
    offsetTop = href === "#" ? 0 : $(href).offset().top-topMenuHeight+1;
    $('html, body').stop().animate({ 
        scrollTop: offsetTop
    }, 1000);
    e.preventDefault();
});

$(window).scroll(function(){
    var fromTop = $(this).scrollTop()+topMenuHeight;

    var cur = scrollItems.map(function(){
        if ($(this).offset().top < fromTop)
            return this;
    });
    cur = cur[cur.length-1];
    var id = cur && cur.length ? cur[0].id : "";

    if (lastId !== id) {
        lastId = id;
        menuItems
        .parent().removeClass("active")
        .end().filter("[href=#"+id+"]").parent().addClass("active");
    }                   
});

});






