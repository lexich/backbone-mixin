/*
 * grunt-image-preload
 * https://github.com/lexich/grunt-image-preload
 *
 * Copyright (c) 2013 Efremov Alexey (lexich)
 * Licensed under the MIT license.
 */

'use strict';

module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({    

    // Before generating any new files, remove any previously-created files.
    clean: {
      dist: ['build'],
    },
    coffee:{
      dist:{
        options:{
          bare:true
        },
        files:{
          "build/backbone-mixin.js":"dist/backbone-mixin.coffee"
        }  
      }      
    },
    uglify:{
      dist:{
        files:{
          "build/backbone-mixin.min.js":"build/backbone-mixin.js"
        }
      }
    },
    docco:{
      dist:{
        src: "dist/backbone-mixin.coffee",
        dest: "."
      }
    },
    version:{
      defaults:{
        src:[
          "build/*.js",
          "bower.json"
        ]
      }
    },
    karma: {
      options:{
        configFile: 'karma.conf.js',
        runnerPort: 9999,        
        //browsers: ['PhantomJS'],        
      },
      dist: {
        singleRun: true
      },
      watch:{}
    }
  });  
  grunt.registerTask('compile', [
    'karma:dist',
    'clean:dist', 
    'coffee:dist', 
    'uglify:dist'  
  ]);

  // By default, lint and run all tests.
  grunt.registerTask('default', ['compile']);

  // These plugins provide necessary tasks.  
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-karma');
  grunt.loadNpmTasks('grunt-docco');
  grunt.loadNpmTasks('grunt-version');
};