import groovy.io.FileType
import java.util.regex.Matcher
import java.util.regex.Pattern
import java.nio.file.Files

String FMK_DIR = 'pos'

def dir = new File( FMK_DIR )
def prefix = ""
def pattern = ~/.*prg$/

dir.eachFileRecurse (FileType.FILES) { file ->
  if ( pattern.matcher( file.name ).matches() ) {

    println file.parent
    println file.name.toString()
    
    prefix = file.parent.toString().replaceAll(/\./) {
      'fmk'
    }
    
    prefix = prefix.replaceAll(/\//) { 
     '_'
    }
  
    new_file_name = '../fmk_hb/' + prefix + '_' + file.name

    println "copy ${file} => ${new_file_name}"
    //Files.copy( file.name as java.lang.String , new_file_name as java.lang.String )  

    (new AntBuilder()).copy( file: file.toString() ,  toFile: new_file_name) 

  }

}
