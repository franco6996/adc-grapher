public int progressBarValue = 0;

public void progressBarWindow()
{
 
    // create a frame
    JFrame f;
 
    JProgressBar b;
  
    // create a frame
    f = new JFrame("Loading...");
 
    // create a panel
    JPanel p = new JPanel( new BorderLayout() );
 
    // create a progressbar
    b = new JProgressBar(0, 100);
     
    // set initial value
    progressBarValue = 0;
    b.setValue(0);
 
    b.setStringPainted(true);
    // add progressbar
    
    p.add(b, BorderLayout.WEST);
    
    // add panel
    f.add(p);
 
    // set the size of the frame
    f.setSize(350, 100);
    f.setVisible(true);
    Dimension d = new Dimension(300,40);
 /* fill  */
   while ( progressBarValue < 100 ) {
     b.setValue( progressBarValue );
     b.setSize(new Dimension(280,35));
     b.setLocation(20, 5);
     p.setSize( d );
     delay(50);
   }
   f.dispose();
}
