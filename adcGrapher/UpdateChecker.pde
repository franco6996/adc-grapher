import java.awt.Desktop;
import java.net.URI;
import java.net.URL;
import java.io.IOException;
import java.awt.Component;
import java.net.URISyntaxException;

void checkUpdates() {
  // Open the web file that contains the last SW version released.
  String[] webFileLines = loadStrings("https://raw.githubusercontent.com/franco6996/seed-analizer/master/version");
  if ( webFileLines == null)
    return;
    
  String swWebVersion = webFileLines[0];  // put the version into a string
  
  switch ( versionCompare(swVersion, swWebVersion) ) {
    case -1:  // if new version available
      String[] options = {"Download", "Not now"};
      int i = javax.swing.JOptionPane.showOptionDialog(null,"New version available!", "Update Checker",
                javax.swing.JOptionPane.DEFAULT_OPTION, javax.swing.JOptionPane.INFORMATION_MESSAGE,
                null, options, options[1]);
      if ( i == 0 ) {
        String url = "https://github.com/franco6996/seed-analizer/releases";
        try {
          Desktop.getDesktop().browse( new URI(url) );
        } catch (IOException | URISyntaxException e1) {
            e1.printStackTrace();
            // TODO localize!
            javax.swing.JOptionPane.showMessageDialog(
                    null,
                    "oops - could not show url ('" + url + "'): "
                            + e1.toString(), "oops",
                    javax.swing.JOptionPane.ERROR_MESSAGE | javax.swing.JOptionPane.OK_OPTION);
        }
        System.exit(0);
      }
      break;
    default:  // if this version is the lastest or newer than web
      break;
  }
  
}

// Method to compare two versions.
// Returns 1 if v2 is smaller, -1 if v1 is smaller, 0 if equal
static int versionCompare(String v1, String v2)  {
  // vnum stores each numeric part of version
  int vnum1 = 0, vnum2 = 0;
   
  // loop until both String are processed
  for (int i = 0, j = 0 ; (i < v1.length()  ||  j < v2.length() ) ; ) {
    // Storing numeric part of version 1 in vnum1
    while (i < v1.length() && v1.charAt(i) != '.') {
        vnum1 = vnum1 * 10 + (v1.charAt(i) - '0');
        i++;
    }
   
    // storing numeric part of version 2 in vnum2
    while (j < v2.length() && v2.charAt(j) != '.') {
        vnum2 = vnum2 * 10 + (v2.charAt(j) - '0');
        j++;
    }
   
    if (vnum1 > vnum2)
        return 1;
    if (vnum2 > vnum1)
        return -1;
   
    // if equal, reset variables and go for next numeric part
    vnum1 = vnum2 = 0;
    i++;
    j++;
  }
  return 0;
}
