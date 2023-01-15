
$.sub( 'config:init', function(){
    $('#btnBackupconfig').on('click', function(e){
        e.preventDefault();
        $.pub( 'config:backup' );
    });
    $('#btnUploadconfig').on('click', function(e){
        e.preventDefault();
        $.pub( 'config:upload' );
    });
});