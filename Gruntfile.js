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
    rename:{
      docs:{
        src:"docs/backbone-mixin.html",
        dest:"docs/index.html"
      }      
    },    
    git_deploy:{
      dist:{
        options:{
          url:"git@github.com:lexich/backbone-mixin.git",
          branch:"gh-pages",
          message:"update documentation"
        },
        src:"docs"
      }
    },
    version:{
      dist:{
        src:[
          "build/*.js",
          "dist/*.coffee",
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
      watch:{
        options:{
          browsers: ['Chrome'],
        }
      }
    }
  });  
  grunt.registerTask('build', [
    'karma:dist',
    'clean:dist', 
    'coffee:dist', 
    'uglify:dist',
    'version:dist'
  ]);
  grunt.registerTask('docs', [
    'docco:dist',
    'rename:docs',
    'git_deploy:dist'    
  ]);

  // By default, lint and run all tests.
  grunt.registerTask('default', ['build']);

  // These plugins provide necessary tasks.  
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-karma');
  grunt.loadNpmTasks('grunt-docco');
  grunt.loadNpmTasks('grunt-version');
  grunt.loadNpmTasks('grunt-git-deploy');
  grunt.loadNpmTasks('grunt-rename');
};