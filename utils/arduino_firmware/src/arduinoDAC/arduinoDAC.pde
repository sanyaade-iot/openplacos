#include <CmdMessenger.h>
#include <RCSwitch.h>
#include <dht11.h>
#include <Streaming.h>
#include <Base64.h>

dht11 DHT11;
RCSwitch mySwitch = RCSwitch();
char tristate[13]; 
char field_separator = ' ';
char command_separator = ';';
// Instantiate Messenger object with the default separator (the space character)
CmdMessenger message = CmdMessenger(Serial,field_separator,command_separator); 

enum
{
  kCOMM_ERROR    = 000, // Lets Arduino report serial port comm error back to the PC (only works for some comm errors)
  kACK           = 001, // Arduino acknowledges cmd was received
  kARDUINO_READY = 002, // After opening the comm port, send this cmd 02 from PC to check arduino is ready
  kERR           = 003, // Arduino reports badly formatted cmd, or cmd not recognised

  // Now we can define many more 'send' commands, coming from the arduino -> the PC, eg
  // kICE_CREAM_READY,
  // kICE_CREAM_PRICE,
  // For the above commands, we just call cmdMessenger.sendCmd() anywhere we want in our Arduino program.

  kSEND_CMDS_END, // Mustnt delete this line
};

messengerCallbackFunction messengerCallbacks[] = 
{
  pin_mode,
  digital_write,
  digital_read,
  analog_read,
  pwm_write,
  rcswitch,
  dht11_read,
  NULL
};

void pin_mode() {
   int pin = message.readInt();
   
   if (message.checkString((char*) "out") or message.checkString((char*) "output")) { // pin #pinnumber out
     pinMode(pin,OUTPUT);
     return;
   }
   if (message.checkString((char*) "in") or message.checkString((char*) "input")) { // pin #pinnumber in
     pinMode(pin,INPUT);
     return;
   }  
}

void digital_write() {
  int pin = message.readInt();

  if (message.checkString((char*) "low") or message.checkString((char*) "0")) {  // pin #pinnumber 0
   digitalWrite(pin,0);
   return;
  }
  if (message.checkString((char*) "high") or message.checkString((char*) "1")) {  // pin #pinnumber 1
   digitalWrite(pin,1);
   return;
  }
}

void digital_read() {
  int pin = message.readInt();

  int val = digitalRead(pin);
  
  Serial.print("6 ");
  Serial.print(pin);
  Serial.print(" ");
  Serial.println(val);
  return;

}

void analog_read() {
  int pin = message.readInt();
  long val = analogRead(pin);    // read the input pin
  for (int i=1;i<100;i++) {
    val += analogRead(pin);
  }
  Serial.print("7 ");
  Serial.print(pin);
  Serial.print(" ");
  Serial.println(((float)val)/100);
  return; 
}

// 8
void pwm_write() {
  int pin = message.readInt();
  int duty = message.readInt();
  analogWrite(pin,duty);
  return;
}

void rcswitch() {
  int pin = message.readInt();
  message.copyString(tristate,13);

  mySwitch.enableTransmit(pin);
  mySwitch.sendTriState(tristate);
  return;  
}

void dht11_read() {
  int pin = message.readInt();
  int chk = DHT11.read(pin);

   Serial.print("10 ");
   Serial.print(pin);
   Serial.print(" ");
   Serial.print((float)DHT11.humidity);
   Serial.print(" ");
   Serial.println((float)DHT11.temperature);
 
  return;  
} 
// Create the callback function

 //if ( message.checkString("led") ) {
   //int pin = 13;
   //if (message.checkString("off") ) {  
     //digitalWrite(pin,0);
     //return;
   //}
   //if (message.checkString("on")) { 
     //digitalWrite(pin,1);
     //return;
   //}  
 //}
 

 //if ( message.checkString("rcswitch") ) {
   //int pin = message.readInt();
   //message.copyString(tristate,13);
   
   //mySwitch.enableTransmit(pin);
   //mySwitch.sendTriState(tristate);
   //return;  
 //}

 //if ( message.checkString("dht11") ) {
   //int pin = message.readInt();
   //dht11readCallback(pin);
   //return;  
 //}  

 //message.readInt();
 //}      

//}

// ------------------ D E F A U L T  C A L L B A C K S -----------------------

void arduino_ready()
{
  // In response to ping. We just send a throw-away Acknowledgement to say "im alive"
  message.sendCmd(kACK,(char*) "Arduino ready");
}

void unknownCmd()
{
  // Default response for unknown commands and corrupt messages
  message.sendCmd(kERR,(char*) "Unknown command");
}

// ------------------ S E T U P ----------------------------------------------

void attach_callbacks(messengerCallbackFunction* callbacks)
{
  int i = 0;
  int offset = kSEND_CMDS_END;
  while(callbacks[i])
  {
    message.attach(offset+i, callbacks[i]);
    i++;
  }
}

void setup() {
  // Initiate Serial Communication
  Serial.begin(115200); 
  // Attach the callback function to the Messenger
  message.print_LF_CR();   // Make output more readable whilst debugging in Arduino Serial Monitor
  // Attach default / generic callback methods
  message.attach(kARDUINO_READY, arduino_ready);
  message.attach(unknownCmd);

  // Attach my application's user-defined callback methods
  attach_callbacks(messengerCallbacks);

  arduino_ready();

}


void loop() {
  // The following line is the most effective way of using Serial and Messenger's callback
  message.feedinSerialData();

}


