// BANANA BAY
// A tiny tropical holiday, drawn entirely in the Image pass.
// Shadertoy: paste into Image. No channels, textures or buffers needed.
// Hold the mouse button to bring the sunshine to your cursor.
// Change SPEED to adjust the monkey animation.

#define SPEED 1.0
#define PI 3.14159265359
#define TAU 6.28318530718

float AA = 0.001;
const vec3 INK = vec3(0.115, 0.185, 0.155);
const vec3 FUR = vec3(0.43, 0.235, 0.12);
const vec3 FACE = vec3(1.0, 0.77, 0.45);

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

float ellipse(vec2 p, vec2 r) {
    return (length(p / r) - 1.0) * min(r.x, r.y);
}

float segment(vec2 p, vec2 a, vec2 b) {
    vec2 v = b-a;
    float h = clamp(dot(p-a,v)/max(dot(v,v),0.00001),0.0,1.0);
    return length(p-a-h*v);
}

vec2 bezier(vec2 a, vec2 b, vec2 c, float t) {
    return mix(mix(a,b,t),mix(b,c,t),t);
}

void paint(inout vec3 c, float d, vec3 color) {
    c = mix(c, color, 1.0-smoothstep(-AA,AA,d));
}

void shape(inout vec3 c, float d, vec3 color, float edge) {
    paint(c,d,INK);
    paint(c,d+edge,color);
}

void line(inout vec3 c, vec2 p, vec2 a, vec2 b, float w, vec3 color) {
    paint(c,segment(p,a,b)-w,color);
}

void sparkle(inout vec3 c, vec2 p, float size, float turn, vec3 color) {
    p = rot(turn)*p;
    float star = min(ellipse(p,vec2(size,size*0.17)),
                     ellipse(p,vec2(size*0.17,size)));
    paint(c,star,color);
}

void cloud(inout vec3 c, vec2 p, vec2 center, float size) {
    vec2 q = (p-center)/size;
    float d = ellipse(q-vec2(0.0,0.0),vec2(0.35,0.075));
    d = min(d, length(q-vec2(-0.14,0.045))-0.105);
    d = min(d, length(q-vec2(0.015,0.095))-0.145);
    d = min(d, length(q-vec2(0.19,0.04))-0.095);
    vec3 shade = mix(vec3(0.77,0.94,0.89),vec3(1.0,0.985,0.85),
                     smoothstep(-0.08,0.12,q.y));
    paint(c,d*size,shade);
}

// Curved bananas have a dark stalk, rounded peel, and a warm inner seam.
void banana(inout vec3 c, vec2 p, float size, float angle) {
    vec2 q = rot(angle)*p/size;
    if(abs(q.x)>0.65 || abs(q.y)>0.45) return;
    float d = 100.0;
    float seam = 100.0;
    vec2 last = vec2(-0.43,0.16);
    vec2 lastInner = last+vec2(0.0,0.038);
    for (int i=1;i<=20;i++) {
        float t = float(i)/20.0;
        vec2 v = bezier(vec2(-0.43,0.16),vec2(-0.12,-0.53),vec2(0.43,0.17),t);
        float radius = 0.027+0.09*pow(sin(PI*t),0.6);
        d = min(d,segment(q,last,v)-radius);
        vec2 vi = v+vec2(0.0,0.04);
        seam = min(seam,segment(q,lastInner,vi)-0.008);
        last=v; lastInner=vi;
    }
    shape(c,d*size,vec3(1.0,0.78,0.12),0.025*size);
    paint(c,seam*size,vec3(1.0,0.93,0.38));
    paint(c,(segment(q,vec2(0.43,0.17),vec2(0.46,0.26))-0.035)*size,vec3(0.36,0.31,0.08));
    paint(c,(length(q-vec2(-0.43,0.16))-0.035)*size,vec3(0.36,0.25,0.09));
}

void bunch(inout vec3 c, vec2 p, float size, float angle) {
    vec2 q = rot(angle)*p;
    banana(c,q-vec2(-0.12,0.12)*size,size*0.92,-0.25);
    banana(c,q-vec2(0.07,0.04)*size,size,0.06);
    banana(c,q-vec2(0.18,-0.07)*size,size*0.82,0.35);
}

void grass(inout vec3 c, vec2 p, vec2 pos, float size) {
    vec2 q = (p-pos)/size;
    line(c,q,vec2(0.0),vec2(-0.10,0.16),0.023,vec3(0.22,0.48,0.20));
    line(c,q,vec2(0.0),vec2(0.025,0.22),0.024,vec3(0.18,0.41,0.19));
    line(c,q,vec2(0.0),vec2(0.13,0.12),0.023,vec3(0.32,0.58,0.22));
}

void palm(inout vec3 c, vec2 p, vec2 base, float size, float lean, float time) {
    vec2 q = (p-base)/size;
    if(abs(q.x)>0.85 || q.y<-0.09 || q.y>1.37) return;
    float oldAA=AA; AA/=size;
    vec2 crown=vec2(lean+0.022*sin(time*1.2+lean*8.0),0.88);
    vec2 prev=vec2(0.0);
    for(int i=1;i<=12;i++) {
        float t=float(i)/12.0;
        vec2 now=bezier(vec2(0.0),vec2(-lean*0.2,0.46),crown,t);
        float d=segment(q,prev,now)-(0.067-0.031*t);
        shape(c,d,mix(vec3(0.52,0.29,0.14),vec3(0.82,0.53,0.25),
                    smoothstep(-0.06,0.03,q.x-now.x)),0.009);
        if(i<12) line(c,q,now-vec2(0.035,0.008),now+vec2(0.027,0.006),0.008,vec3(0.42,0.29,0.15));
        prev=now;
    }
    for(int j=0;j<7;j++) {
        float side=j<3?-1.0:1.0;
        float k=j<3?float(j):float(j-3);
        vec2 tip=crown+vec2(side*(0.43+0.075*k),0.17-0.16*k);
        if(j==6) tip=crown+vec2(-0.06,0.40);
        tip.x+=0.04*sin(time*1.4+float(j)*1.7);
        vec2 ctrl=crown+vec2((tip.x-crown.x)*0.55,0.32+0.03*k);
        float leaf=100.0, vein=100.0;
        vec2 last=crown;
        for(int i=1;i<=16;i++) {
            float t=float(i)/16.0;
            vec2 v=bezier(crown,ctrl,tip,t);
            float radius=0.059*pow(sin(PI*t),0.7)+0.004;
            leaf=min(leaf,segment(q,last,v)-radius);
            vein=min(vein,segment(q,last,v)-0.004);
            last=v;
        }
        vec3 green=mix(vec3(0.035,0.35,0.26),vec3(0.28,0.66,0.30),0.3+0.7*float(j%2));
        shape(c,leaf,green,0.008);
        paint(c,vein,vec3(0.53,0.73,0.33));
    }
    shape(c,length(q-crown-vec2(-0.04,-0.035))-0.058,vec3(0.43,0.27,0.12),0.008);
    shape(c,length(q-crown-vec2(0.045,-0.025))-0.055,vec3(0.56,0.36,0.15),0.008);
    shape(c,length(q-crown-vec2(0.0,-0.10))-0.052,vec3(0.66,0.42,0.18),0.008);
    AA=oldAA;
}

// Each monkey approaches its banana, crouches, picks it up, and cheers.
// The cycle is deterministic, so no feedback buffer is needed.
void monkey(inout vec3 c, vec2 p, vec2 base, float size, float id, float time) {
    float cycle=fract(time*0.125+id*0.29);
    float walk=smoothstep(0.03,0.43,cycle);
    float back=smoothstep(0.80,1.0,cycle);
    float x=mix(-0.23,0.17,walk)-0.40*back;
    float pickup=smoothstep(0.535,0.64,cycle);
    float celebrate=smoothstep(0.57,0.66,cycle)*(1.0-smoothstep(0.77,0.83,cycle));
    float crouch=sin(PI*clamp((cycle-0.43)/0.17,0.0,1.0));
    float walking=(1.0-smoothstep(0.41,0.45,cycle))+smoothstep(0.80,0.85,cycle);
    float stride=sin(time*9.0+id*4.0)*walking;
    float hop=0.033*abs(stride)+0.065*abs(sin(time*9.0))*celebrate;
    vec2 pos=base+vec2(x,hop-0.035*crouch);
    vec2 groundBanana=base+vec2(0.33,0.06);
    vec3 scarf=id<0.5?vec3(0.95,0.30,0.20):(id<1.5?vec3(0.13,0.64,0.64):vec3(0.48,0.37,0.78));
    float shadow=ellipse(p-base-vec2(x+0.025,-0.014),vec2(size*0.33,size*0.082));
    c=mix(c,vec3(0.58,0.42,0.20),0.24*(1.0-smoothstep(-0.005,0.022,shadow)));

    if(cycle<0.535) {
        float bob=0.007*sin(time*3.0+id*3.0);
        bunch(c,p-groundBanana-vec2(0.0,bob),size*0.28,-0.25);
        sparkle(c,p-groundBanana-vec2(0.01,0.075),0.013*(0.75+0.25*sin(time*5.0)),0.0,vec3(1.0,0.99,0.67));
    }
    vec2 q=(p-pos)/size;
    if(abs(q.x)>0.90 || q.y<-0.16 || q.y>1.85) return;
    float oldAA=AA; AA/=size;
    float tilt=0.03*stride-0.10*crouch;
    q=rot(tilt)*(q-vec2(0.0,0.35))+vec2(0.0,0.35);
    float flip=cycle>0.84?-1.0:1.0;
    q.x*=flip;

    // A curled tail, drawn behind the body.
    float tail=100.0;
    vec2 last=vec2(-0.15,0.30);
    for(int i=1;i<=26;i++) {
        float t=float(i)/26.0;
        vec2 v;
        if(t<0.4) v=bezier(vec2(-0.15,0.30),vec2(-0.58,0.12),vec2(-0.54,0.51),t/0.4);
        else {
            float a=(t-0.4)/0.6*TAU*0.83;
            float r=mix(0.13,0.035,(t-0.4)/0.6);
            v=vec2(-0.41,0.51)+r*vec2(-cos(a),sin(a));
        }
        v.y+=0.018*sin(time*3.0+t*3.0)*t;
        tail=min(tail,segment(q,last,v)-0.036);
        last=v;
    }
    shape(c,tail,FUR,0.012);

    // Feet and legs swing in opposite directions while walking.
    vec2 leftFoot=vec2(-0.14-0.085*stride,0.055+max(0.0,stride)*0.05);
    vec2 rightFoot=vec2(0.16+0.085*stride,0.055+max(0.0,-stride)*0.05);
    shape(c,segment(q,vec2(-0.12,0.28),leftFoot)-0.067,FUR,0.012);
    shape(c,segment(q,vec2(0.12,0.28),rightFoot)-0.067,FUR,0.012);
    shape(c,ellipse(q-leftFoot-vec2(-0.015,0.0),vec2(0.105,0.053)),FACE*0.88,0.012);
    shape(c,ellipse(q-rightFoot-vec2(0.025,0.0),vec2(0.105,0.053)),FACE*0.88,0.012);

    // The front arm reaches to the fruit, then lifts it overhead.
    vec2 leftHand=mix(vec2(-0.28,0.29-0.045*stride),vec2(-0.36,0.85),celebrate);
    vec2 rightHand=vec2(0.28,0.31+0.055*stride);
    rightHand=mix(rightHand,vec2(0.43,0.16),crouch);
    rightHand=mix(rightHand,vec2(0.35,0.92),pickup*(1.0-back));
    shape(c,segment(q,vec2(-0.17,0.49),leftHand)-0.060,FUR,0.011);
    shape(c,segment(q,vec2(0.17,0.49),rightHand)-0.060,FUR,0.011);
    shape(c,ellipse(q-vec2(0.0,0.35),vec2(0.218,0.265)),FUR,0.015);
    paint(c,ellipse(q-vec2(0.022,0.32),vec2(0.137,0.176)),vec3(0.79,0.49,0.25));
    paint(c,ellipse(q-vec2(0.03,0.36),vec2(0.105,0.13)),vec3(0.88,0.59,0.31));

    // Ears, big rounded head, and a little tuft of hair.
    vec2 head=vec2(0.015,0.76-0.035*crouch);
    shape(c,length(q-head-vec2(-0.252,0.0))-0.116,FUR,0.013);
    paint(c,length(q-head-vec2(-0.253,-0.003))-0.074,vec3(0.91,0.56,0.34));
    shape(c,length(q-head-vec2(0.252,0.0))-0.116,FUR,0.013);
    paint(c,length(q-head-vec2(0.253,-0.003))-0.074,vec3(0.91,0.56,0.34));
    shape(c,ellipse(q-head,vec2(0.274,0.256)),FUR,0.015);
    shape(c,ellipse(rot(-0.5)*(q-head-vec2(-0.035,0.224)),vec2(0.052,0.088)),FUR,0.012);
    vec2 h=q-head;
    float mask=min(ellipse(h-vec2(-0.087,0.008),vec2(0.125,0.161)),
                   ellipse(h-vec2(0.087,0.008),vec2(0.125,0.161)));
    mask=min(mask,ellipse(h-vec2(0.0,-0.091),vec2(0.192,0.133)));
    paint(c,mask,FACE);
    paint(c,ellipse(h-vec2(0.014,-0.075),vec2(0.163,0.100)),vec3(1.0,0.83,0.54));

    float blink=1.0-0.88*pow(max(0.0,cos(time*1.45+id*1.8)),32.0);
    for(int i=0;i<2;i++) {
        float side=i==0?-1.0:1.0;
        vec2 eye=vec2(side*0.088,0.042);
        shape(c,ellipse(h-eye,vec2(0.044,0.057*blink)),vec3(1.0,0.99,0.89),0.007);
        paint(c,ellipse(h-eye-vec2(0.012,0.0),vec2(0.022,0.034*blink)),INK);
        if(blink>0.5) paint(c,length(h-eye-vec2(0.007,0.014))-0.008,vec3(1.0));
        line(c,h,vec2(side*0.055,0.123),vec2(side*0.117,0.115),0.012,FUR);
        paint(c,ellipse(h-vec2(side*0.142,-0.072),vec2(0.032,0.018)),vec3(0.96,0.50,0.32));
    }
    paint(c,ellipse(h-vec2(0.015,-0.051),vec2(0.032,0.020)),vec3(0.31,0.20,0.12));
    // Smile: lower half of a small circular arc.
    vec2 mouth=h-vec2(0.018,-0.075);
    float smile=max(abs(length(mouth)-0.068)-0.008,mouth.y+0.012);
    paint(c,smile,INK);
    if(celebrate>0.2) {
        paint(c,ellipse(h-vec2(0.018,-0.117),vec2(0.046,0.031)),INK);
        paint(c,ellipse(h-vec2(0.018,-0.133),vec2(0.027,0.010)),vec3(0.98,0.45,0.34));
    }

    // Colored neckerchiefs make the three collectors easy to follow.
    shape(c,segment(q,vec2(-0.13,0.535),vec2(0.15,0.52))-0.027,scarf,0.008);
    shape(c,segment(q,vec2(0.075,0.52),vec2(0.14,0.425))-0.030,scarf,0.008);
    shape(c,length(q-leftHand)-0.065,FACE,0.011);
    shape(c,length(q-rightHand)-0.065,FACE,0.011);
    if(cycle>=0.535 && cycle<0.84) {
        bunch(c,q-rightHand-vec2(0.025,0.095),0.31,-0.20+0.1*sin(time*7.0));
    }
    AA=oldAA;

    // The pickup produces a small burst and a floating +1.
    float age=(cycle-0.54)/0.22;
    if(age>0.0 && age<1.0) {
        vec2 center=pos+vec2(0.15,size*1.04);
        for(int j=0;j<6;j++) {
            float a=float(j)*TAU/6.0;
            vec2 v=center+vec2(cos(a),sin(a))*(0.04+age*0.14);
            sparkle(c,p-v,0.018*(1.0-age),a,vec3(1.0,0.98,0.61));
        }
        vec2 r=p-center-vec2(-0.03,0.03+age*0.12);
        float w=0.004*(1.0-age);
        line(c,r,vec2(-0.018,0.0),vec2(0.018,0.0),w,vec3(1.0,0.97,0.70));
        line(c,r,vec2(0.0,-0.018),vec2(0.0,0.018),w,vec3(1.0,0.97,0.70));
        line(c,r,vec2(0.047,-0.021),vec2(0.047,0.024),w,vec3(1.0,0.97,0.70));
        line(c,r,vec2(0.035,0.013),vec2(0.047,0.024),w,vec3(1.0,0.97,0.70));
    }
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float aspect=iResolution.x/iResolution.y;
    float fit=max(1.0,1.65/aspect);
    vec2 p=(2.0*fragCoord-iResolution.xy)/iResolution.y*fit;
    AA=1.4/iResolution.y*fit;
    float time=iTime*SPEED;
    vec3 c=mix(vec3(0.94,0.95,0.72),vec3(0.29,0.73,0.76),
               smoothstep(0.22,1.12,p.y));

    vec2 sun=vec2(0.76,0.62);
    if(iMouse.z>0.0) sun=(2.0*iMouse.xy-iResolution.xy)/iResolution.y*fit;
    c+=vec3(0.11,0.08,0.015)*exp(-length(p-sun)*4.0);
    paint(c,length(p-sun)-0.173,vec3(1.0,0.92,0.57));
    paint(c,abs(length(p-sun)-0.215)-0.002,vec3(0.96,0.94,0.68));

    cloud(c,p,vec2(-0.75+0.025*sin(time*0.13),0.72),0.82);
    cloud(c,p,vec2(1.43+0.035*sin(time*0.12+1.0),0.48),0.65);
    cloud(c,p,vec2(0.1+0.02*sin(time*0.17),0.91),0.47);

    // Distant little island and birds.
    paint(c,ellipse(p-vec2(-1.10,0.248),vec2(0.42,0.053)),vec3(0.33,0.63,0.53));
    for(int i=0;i<3;i++) {
        vec2 bird=p-vec2(-0.23+float(i)*0.13+0.10*sin(time*0.12),0.53+float(i%2)*0.065);
        float flap=0.018+0.010*sin(time*3.8+float(i));
        line(c,bird,vec2(-0.026,flap),vec2(0.0),0.003,vec3(0.25,0.48,0.43));
        line(c,bird,vec2(0.026,flap),vec2(0.0),0.003,vec3(0.25,0.48,0.43));
    }

    // Quiet turquoise ocean with short, moving wave crests.
    vec3 sea=mix(vec3(0.025,0.49,0.57),vec3(0.22,0.75,0.73),smoothstep(-1.2,0.25,p.y));
    float swell=sin(p.y*34.0+sin(p.x*2.8+time*0.4)*1.1-time*1.25);
    sea+=0.022*swell;
    paint(c,p.y-0.235,sea);
    for(int i=0;i<17;i++) {
        float fi=float(i);
        float yy=-1.05+fi*0.076;
        float xx=sin(fi*62.1)*2.5+0.055*sin(time*0.55+fi);
        float width=0.055+0.07*hash21(vec2(fi,4.0));
        vec2 a=vec2(xx,yy+0.009*sin(time+fi));
        line(c,p,a-vec2(width,0.0),a+vec2(width,0.0),0.0035,vec3(0.42,0.81,0.77));
    }

    vec2 island=p-vec2(0.0,-0.39);
    paint(c,ellipse(island-vec2(0.025,-0.02),vec2(1.62,0.535)),vec3(0.14,0.67,0.62));
    paint(c,ellipse(island-vec2(0.01,-0.015),vec2(1.52,0.485)),vec3(0.36,0.79,0.66));
    float beach=ellipse(island,vec2(1.39,0.405));
    float wave=0.018*sin(time*1.6+island.x*4.0);
    paint(c,abs(beach-0.040-wave)-0.006,vec3(0.83,0.96,0.80));
    paint(c,ellipse(island-vec2(0.0,-0.028),vec2(1.39,0.405)),vec3(0.75,0.52,0.27));
    vec3 sand=mix(vec3(0.94,0.70,0.37),vec3(1.0,0.87,0.53),smoothstep(-0.32,0.22,island.y));
    paint(c,beach,sand);
    paint(c,ellipse(island-vec2(0.0,0.11),vec2(1.02,0.205)),vec3(0.46,0.62,0.27));
    paint(c,ellipse(island-vec2(-0.02,0.135),vec2(0.97,0.177)),vec3(0.65,0.73,0.32));
    paint(c,ellipse(island-vec2(0.06,0.10),vec2(0.85,0.139)),vec3(0.72,0.78,0.37));

    // Fine sand flecks, with no external noise texture.
    vec2 cell=floor(p*105.0);
    float dotNoise=hash21(cell);
    if(beach<-0.015 && island.y<0.01 && dotNoise>0.966) {
        float grain=length(fract(p*105.0)-0.5)-0.13;
        c=mix(c,c*vec3(0.84,0.79,0.70),0.35*(1.0-smoothstep(0.0,0.13,grain)));
    }
    grass(c,p,vec2(-0.65,-0.26),0.45);
    grass(c,p,vec2(0.52,-0.24),0.37);
    grass(c,p,vec2(-0.16,-0.20),0.32);

    palm(c,p,vec2(-0.99,-0.30),0.90,0.14,time);
    palm(c,p,vec2(1.01,-0.26),0.91,-0.14,time+1.3);

    // A few coconuts and a pink shell on the shore.
    shape(c,ellipse(p-vec2(-1.03,-0.38),vec2(0.063,0.047)),vec3(0.55,0.34,0.17),0.007);
    paint(c,ellipse(p-vec2(-1.047,-0.366),vec2(0.027,0.020)),vec3(0.72,0.49,0.25));
    shape(c,ellipse(p-vec2(1.08,-0.40),vec2(0.055,0.044)),vec3(0.52,0.31,0.15),0.006);
    shape(c,ellipse(p-vec2(-1.11,-0.53),vec2(0.039,0.026)),vec3(0.98,0.57,0.42),0.004);
    for(int j=0;j<3;j++) {
        float x=-1.125+float(j)*0.014;
        line(c,p,vec2(-1.11,-0.551),vec2(x,-0.515),0.0015,vec3(1.0,0.79,0.59));
    }

    monkey(c,p,vec2(0.02,-0.36),0.39,1.0,time);
    monkey(c,p,vec2(-0.65,-0.57),0.47,0.0,time);
    monkey(c,p,vec2(0.65,-0.59),0.48,2.0,time);

    grass(c,p,vec2(-0.91,-0.61),0.34);
    grass(c,p,vec2(1.16,-0.51),0.30);
    // Very subtle paper grain, then a warm vignette.
    c+=(hash21(fragCoord)-0.5)*0.008;
    vec2 uv=fragCoord/iResolution.xy;
    c*=1.0-0.12*pow(length((uv-0.5)*vec2(1.05,0.9)),2.0);
    fragColor=vec4(clamp(c,0.0,1.0),1.0);
}
