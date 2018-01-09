var exec = require('cordova/exec');

exports.gizDownload = function (arg0, success, error) {
    exec(success, error, 'GizDownloadMedia', 'gizDownload', [arg0]);
};

exports.gizCancelDownload = function (arg0, success, error) {
    exec(success, error, 'GizDownloadMedia', 'gizCancelDownload', [arg0]);
};



