import java.text.*;
import java.util.*;
import java.awt.*;
import java.applet.Applet;
import java.awt.event.*;


class PhasorPanel extends Panel
    implements Runnable, MouseListener, MouseMotionListener {

    int envelope = 0;
    int weight = 0;
    int zmax = 200;
    int z = 0;
    int counter = 0;
    PhasorDemo phasor;
    boolean running = false;
    Thread me;
    int sign = 1;
    int height;
    int width;
    int centerX;
    int centerY;
    int centerX2;
    int centerY2;
    int x;
    int y;
    int x_component;
    int y_component;
    int length_comp;
    int radius_init;
    int radius;
    int radius_final;
    double speed;
    int offset;
    double pi = 3.14159265358979;
    double angle = 0.0;
    NumberFormat form;

    Font default_font = new Font("Verdana",Font.PLAIN,10);
    
    PhasorPanel(PhasorDemo phasor) {
	this.phasor = phasor;
    }

    public void run() {
        Thread current = Thread.currentThread();
	initialize();
	repaint();
	while (current == me) {
	    if (running && z < zmax) {
		counter++;
		animate();
	    }
	    try {
		Thread.sleep(weight);
	    } catch (InterruptedException e) {
		break;
	    }
	}
    }

    public void initialize() {
	// initial conditions
	Dimension d = getSize();
	height = d.height;
	width = d.width;
	centerX = width/2 - width/4;
	centerY = height/2 + height/4;
	angle = offset*pi/180;
	x = (int)Math.round(radius*Math.cos(angle));
	y = (int)Math.round(radius*Math.sin(angle));
	
	radius_init = radius;

	// draw the Re/Im component axis - assume length of 250/sqrt(2)
	x_component = centerX+radius_init*3;
	y_component = centerY-radius_init*3;
	length_comp = (int)Math.round(zmax/Math.sqrt(2));

    }

    public void paint(Graphics g) {

	// make printable drawing
	if (!running) {
	    int z_temp = z;
	    for (int i = counter; i >= 0; i--) {
		if ((i % speed) == 0) {
		    z_temp--;
		}
		double angle_temp;
		if (sign > 0) {
		    angle_temp = ((i*2+offset)%360)*pi/180;
		} else {
		    int temp = i*(-2)+offset;
		    if (temp > 0)
			temp -= 360;
		    angle_temp = (360-(Math.abs(temp)%360))*pi/180;
		}
		int radius_temp = (int)Math.round(Math.exp(0.001*envelope*z_temp)*radius_init);
		int x_temp =
		    centerX
		    +(int)Math.round(radius_temp*Math.cos(angle_temp))
		    +z_temp;
		int y_temp =
		    centerY
		    -(int)Math.round(radius_temp*Math.sin(angle_temp))
		    -z_temp;
		if ((i % 2) == 0) {
		    g.setColor(Color.green);
		    if (3*pi/4 < angle_temp && angle_temp < 7*pi/4)
			g.setColor(Color.lightGray);
		    g.drawLine(x_temp-2,y_temp+2,x_temp+3,y_temp-3);
		    g.drawLine(x_temp-3,y_temp+1,x_temp+2,y_temp-4);
		}

		// draw the cos/sin curve
		int offset_temp = (int)Math.round(z_temp*length_comp/zmax);
		g.setColor(Color.blue);
		g.fillArc(x_temp-z_temp-1,y_component-offset_temp-1,4,4,0,360);
		g.setColor(Color.red);
		g.fillArc(x_component+offset_temp-1,y_temp+z_temp-1,4,4,0,360);
	    }

	    // draw the moving axis
	    centerX2 = centerX + z;
	    centerY2 = centerY - z;
	    g.setColor(Color.lightGray);
	    g.drawLine(centerX2-radius,centerY2,centerX2+radius,centerY2);
	    g.drawLine(centerX2,centerY2-radius,centerX2,centerY2+radius);
	    g.drawArc(centerX2-radius,centerY2-radius,radius*2,radius*2,135,180);
	    g.setColor(Color.black);
	    g.drawArc(centerX2-radius,centerY2-radius,radius*2,radius*2,-45,180);
	    
	    // only repaint once - we only need this for printing
	    // (printing function calls repaint() and then prints)
	    z = 0;
	    counter = 0;
	}
	
	// draw the initial position
	g.setColor(Color.blue);
	g.fillArc(centerX+x-3,centerY-3,6,6,0,360);
	g.setColor(Color.red);
	g.fillArc(centerX-3,centerY-y-3,6,6,0,360);
	g.setColor(Color.green);
	g.drawLine(centerX+x,centerY,centerX+x,centerY-y);
	g.drawLine(centerX,centerY-y,centerX+x,centerY-y);
	
	// draw the cos/sin axis
	g.setColor(Color.black);
	g.drawLine(x_component,centerY,x_component+length_comp,centerY);
	g.drawLine(x_component,centerY-radius_init,x_component,centerY+radius_init);
	g.drawString("t",x_component+length_comp,centerY-10);
	g.drawString("Im",x_component,centerY-radius_init);
	g.drawLine(centerX,y_component,centerX,y_component-length_comp);
	g.drawLine(centerX-radius_init,y_component,centerX+radius_init,y_component);
	g.drawString("t",centerX,y_component-length_comp-10);
	g.drawString("Re",centerX+radius_init,y_component-10);
	
	// draw the equation
	form = new DecimalFormat("0.00");
	g.setFont(default_font);
	g.drawString
	    ("A exp(st + phi)",
	     width-width/2-width/8-10, height-60);
	g.drawString
	    ("= "+radius_init/10+"exp(("  + envelope + " + j"+(sign*speed)+")t + "
	     +form.format(offset/180.0)+"pi)",
	     width-width/2-width/8, height-45);
	g.drawString
	    ("= "+radius_init/10+"exp("+envelope+"t) cos("+(sign*speed)+"t + "
	     +form.format(offset/180.0)+"pi)",
	     width-width/2-width/8, height-30);
	g.drawString
	    ("  + j"+radius_init/10+"exp("+envelope+"t) sin("+(sign*speed)+"t + "
	     +form.format(offset/180.0)+"pi)",
	     width-width/2-width/8, height-15);
	
	// draw the lines connecting two circles
	g.setColor(Color.black);
	int sqrt2 = (int)Math.ceil(radius_init/Math.sqrt(2));
	g.drawLine(centerX+sqrt2,centerY+sqrt2,centerX+sqrt2+zmax,centerY+sqrt2-zmax);
	g.drawLine(centerX-sqrt2,centerY-sqrt2,centerX-sqrt2+zmax,centerY-sqrt2-zmax);

    	// original axis & circle
	g.setColor(Color.black);
 	g.drawLine(centerX-radius_init*2,centerY,centerX+radius_init*2,centerY);
	g.drawLine(centerX,centerY-radius_init*2,centerX,centerY+radius_init*2);
	g.drawArc(centerX-radius_init,centerY-radius_init,radius_init*2,radius_init*2,0,360);
	g.drawArc(centerX-radius_init+zmax,centerY-radius_init-zmax,radius_init*2,radius_init*2,-45,180);
	g.setColor(Color.lightGray);
	g.drawArc(centerX-radius_init+zmax,centerY-radius_init-zmax,radius_init*2,radius_init*2,135,180);
	g.drawLine(centerX,centerY,centerX+zmax,centerY-zmax);
	g.setColor(Color.black);
	g.drawString("Re", centerX+radius_init*2-10, centerY-10);
	g.drawString("Im", centerX+5, centerY-radius_init*2);
	g.drawString("t", centerX+zmax-20+10,centerY-zmax+20+5);

    }

    synchronized void animate() {

	// redraw the axis
 	Graphics g = getGraphics();
	paint(g);
	
	if ((counter % speed) == 0) {
	    z++;
	}

	// draw the overwritten dots
	int z_temp = z;
	for (int i = counter; i >= 0; i--) {
	    if ((i % speed) == 0) {
		z_temp--;
	    }
	    double angle_temp;
	    if (sign > 0) {
		angle_temp = ((i*2+offset)%360)*pi/180;
	    } else {
		int temp = i*(-2)+offset;
		if (temp > 0)
		    temp -= 360;
		angle_temp = (360-(Math.abs(temp)%360))*pi/180;
	    }
	    int radius_temp = (int)Math.round(Math.exp(0.001*envelope*z_temp)*radius_init);
	    int x_temp =
		centerX
		+(int)Math.round(radius_temp*Math.cos(angle_temp))
		+z_temp;
	    int y_temp =
		centerY
		-(int)Math.round(radius_temp*Math.sin(angle_temp))
		-z_temp;
	    boolean overwritten = false;
	    if ((Math.pow(Math.abs(x_temp-centerX2),2) < Math.pow(radius+5,2)
		 && Math.pow(Math.abs(y_temp-centerY2),2) < Math.pow(radius+5,2))
		|| (Math.pow(Math.abs(x_temp-centerX),2) < Math.pow(radius+5,2)
		    && Math.pow(Math.abs(y_temp-centerY),2) < Math.pow(radius+5,2))) {
		overwritten = true;
	    }
	    if (((i % 2) == 0) && overwritten) {
		g.setColor(Color.green);
		if (3*pi/4 < angle_temp && angle_temp < 7*pi/4)
		    g.setColor(Color.lightGray);
		g.drawLine(x_temp-2,y_temp+2,x_temp+3,y_temp-3);
		g.drawLine(x_temp-3,y_temp+1,x_temp+2,y_temp-4);
	    }
	}

	
	// erase the previous lines
	g.setColor(Color.white);
	g.drawLine(centerX+x,centerY,centerX+x,centerY-y);
	g.drawLine(centerX,centerY-y,centerX+x,centerY-y);
	g.fillArc(centerX+x-3,centerY-y-3,6,6,0,360);

	// dots
	g.fillArc(centerX+x-3,centerY-3,6,6,0,360);
	g.fillArc(centerX-3,centerY-y-3,6,6,0,360);

	// moving axis
	g.drawLine(centerX2-radius,centerY2,centerX2+radius,centerY2);
	g.drawLine(centerX2,centerY2-radius,centerX2,centerY2+radius);
	g.drawArc(centerX2-radius,centerY2-radius,radius*2,radius*2,0,360);


	// envelope calculation
	radius = (int)Math.round(Math.exp(0.001*envelope*z)*radius_init);
	
	
	// draw the new lines
	if (sign > 0) {
	    angle = ((counter*2+offset)%360)*pi/180;
	} else {
	    angle = counter*(-2)+offset;
	    angle = ((angle+360)%360)*pi/180;
	}
	x = (int)Math.round(radius*Math.cos(angle));
	y = (int)Math.round(radius*Math.sin(angle));
	g.setColor(Color.green);
	g.drawLine(centerX+x,centerY,centerX+x,centerY-y);
	g.drawLine(centerX,centerY-y,centerX+x,centerY-y);
	g.fillArc(centerX+x-3,centerY-y-3,6,6,0,360);
	
	// draw the dots
	g.setColor(Color.blue);
	g.fillArc(centerX+x-3,centerY-3,6,6,0,360);
	g.setColor(Color.red);
	g.fillArc(centerX-3,centerY-y-3,6,6,0,360);

	// draw the moving axis
	centerX2 = centerX + z;
	centerY2 = centerY - z;
	g.setColor(Color.lightGray);
 	g.drawLine(centerX2-radius,centerY2,centerX2+radius,centerY2);
	g.drawLine(centerX2,centerY2-radius,centerX2,centerY2+radius);
	g.drawArc(centerX2-radius,centerY2-radius,radius*2,radius*2,0,360);
		
	// draw the cos/sin curve
	int offset_temp = (int)Math.round(z*length_comp/zmax);
	g.setColor(Color.blue);
	g.fillArc(centerX-1+x,y_component-offset_temp-1,4,4,0,360);
	g.setColor(Color.red);
	g.fillArc(x_component+offset_temp-1,centerY-1-y,4,4,0,360);
    }

    //1.1 event handling
    public void mouseClicked(MouseEvent e) {
    }

    public void mousePressed(MouseEvent e) {
    }

    public void mouseReleased(MouseEvent e) {
    }

    public void mouseEntered(MouseEvent e) {
    }

    public void mouseExited(MouseEvent e) {
    }

    public void mouseDragged(MouseEvent e) {
    }

    public void mouseMoved(MouseEvent e) {
    }

    public void start() {
	me = new Thread(this);
	me.start();

    }

    public void stop() {
	me = null;
    }

    public void clear(Graphics g) {
	g.setColor(Color.white);
	g.fillRect(0,0,width,height);
	removeAll();
    }
    
    public void reset(int radius, double offset, int envelope, int speed, int weight) {
	Graphics g = getGraphics();
	clear(g);
	
	this.radius = radius * 10;
	while (offset > 2 || offset < 0) {
	    if (offset > 0)
		offset = offset - 2;
	    else
		offset = offset + 2;
	}
	this.offset = (int)Math.round(offset*180);
	this.envelope = envelope;
	this.weight = weight;
	counter = 0;
	z = 0;
	radius_init = this.radius;
	if (speed < 0) {
	    this.speed = -speed;
	    sign = -1;
	} else {
	    this.speed = speed;
	    sign = 1;
	}

	running = false;

	initialize();
	paint(g);
	try {
	    Thread.sleep(50);
	} catch (InterruptedException e) {
	}
    }
    
}


public class PhasorDemo extends Applet implements ActionListener {

    PhasorPanel panel;
    Panel controlPanel;

    Button run = new Button("Run");
    Button stop = new Button("Stop");
    Button reset = new Button("Reset");

    int default_radius = 4;
    double default_phase = -0.5;
    int default_envelope = 0;
    int default_speed = 3;
    int default_weight = 5;
    
    TextField radius;
    TextField offset;
    TextField envelope;
    TextField speed;
    TextField weight;

    Font default_font = new Font("Verdana",Font.PLAIN,10);
    
    public void init() {
	setFont(default_font);
	setLayout(new BorderLayout());
	setBackground(Color.white);

	GridBagLayout buttonLayout = new GridBagLayout();
	GridBagConstraints c = new GridBagConstraints();
	panel = new PhasorPanel(this);
	panel.setFont(default_font);
	add("Center", panel);
	controlPanel = new Panel(buttonLayout);
	controlPanel.setFont(default_font);
	add("South", controlPanel);

	c.fill = GridBagConstraints.BOTH;
	c.gridx=0;
	c.gridy=0;
	Label lb_a = new Label("A",Label.RIGHT);
	buttonLayout.setConstraints(lb_a,c);
	controlPanel.add(lb_a);

	c.gridx=1;
	radius = new TextField(""+default_radius,3);
	buttonLayout.setConstraints(radius,c);
	controlPanel.add(radius);

	c.gridx=2;
	Label lb_phi = new Label("phi(*pi)",Label.RIGHT);
	buttonLayout.setConstraints(lb_phi,c);
	controlPanel.add(lb_phi);

	c.gridx=3;
	offset = new TextField(""+default_phase,3);
	buttonLayout.setConstraints(offset,c);
	controlPanel.add(offset);

	c.gridx=4;
	Label lb_re = new Label("Re(s)",Label.RIGHT);
	buttonLayout.setConstraints(lb_re,c);
	controlPanel.add(lb_re);

	c.gridx=5;
	envelope = new TextField(""+default_envelope,3);
	buttonLayout.setConstraints(envelope,c);
	controlPanel.add(envelope);
	
	c.gridx=6;
	Label lb_im = new Label("Im(s)",Label.RIGHT);
	buttonLayout.setConstraints(lb_im,c);
	controlPanel.add(lb_im);

	c.gridx=7;
	speed = new TextField(""+default_speed,3);
	buttonLayout.setConstraints(speed,c);
	controlPanel.add(speed);
	
	c.gridy=1;

	c.gridx=3;
	Label unit_phi = new Label("radians");
	buttonLayout.setConstraints(unit_phi,c);
	controlPanel.add(unit_phi);
	
	c.gridx=5;
	Label unit_re = new Label("s^(-1)");
	buttonLayout.setConstraints(unit_re,c);
	controlPanel.add(unit_re);

	c.gridx=7;
	Label unit_im = new Label("rad/s");
	buttonLayout.setConstraints(unit_im,c);
	controlPanel.add(unit_im);

	c.gridy=2;
	
	c.gridx=2;
	Label lb_wt = new Label("Weight",Label.RIGHT);
	buttonLayout.setConstraints(lb_wt,c);
	controlPanel.add(lb_wt);

	c.gridx=3;
	weight = new TextField(""+default_weight,4);
	buttonLayout.setConstraints(weight,c);
	controlPanel.add(weight);
	
	c.gridx=5;
	buttonLayout.setConstraints(run,c);
	controlPanel.add(run);
	run.addActionListener(this);

	c.gridx=6;
	buttonLayout.setConstraints(stop,c);
	controlPanel.add(stop);
	stop.addActionListener(this);

	c.gridx=7;
	buttonLayout.setConstraints(reset,c);
	controlPanel.add(reset);
	reset.addActionListener(this);

	panel.reset(default_radius,default_phase,default_envelope,default_speed,default_weight);
    }

    public void destroy() {
        remove(panel);
        remove(controlPanel);
    }

    public void start() {
	panel.start();
    }

    public void stop() {
	panel.stop();
    }

    public void actionPerformed(ActionEvent e) {
	Object src = e.getSource();
	int radius_val = Integer.parseInt(radius.getText().trim());
	// 1.1 way - lame
	Double temp = new Double(offset.getText().trim());
	double offset_val = temp.doubleValue();
	int envelope_val = Integer.parseInt(envelope.getText().trim());
	int speed_val = Integer.parseInt(speed.getText().trim());
	int weight_val = Integer.parseInt(weight.getText().trim());

	// reject an inappropriate value
	if (radius_val < 1) {
	    radius_val = 1;
	    radius.setText("1");
        }
	if (weight_val < 0) {
	    weight_val = 0;
	    weight.setText("0");
	}

	if (src == run) {
	    panel.reset(radius_val, offset_val, envelope_val, speed_val, weight_val);
	    panel.running = true;
	    start();
	}
	if (src == stop) {
	    panel.running = false;
	}
	if (src == reset) {
	    panel.running = false;
	    panel.reset(radius_val, offset_val, envelope_val, speed_val, weight_val);
	}
    }
}








