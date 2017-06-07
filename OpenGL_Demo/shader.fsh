void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    
    //If you have any questions, you can send me Email:helenhololens@gmail.com
    
    //get source_uv
    vec2 source_uv = fragCoord.xy / iResolution.xy;
    //assume your distortion center coordinate is (0.5,0.5),you can use your distortion center instead.
    vec2 distortion_center = vec2(0.5,0.5);
    //Define algorithm dependent variables
    float distortion_x,distortion_y,rr,r2,theta;
    //define distortion coefficient K1 and K2 ,In most cases we can only adjust K1. then K2 parameters can be adjusted more perfect Effect
    //iGlobalTime is used for Real-time change.
    //K1 < 0 is pincushion distortion
    //K1 >=0 is barrel distortion
    float distortion_k1 = 1.0 * sin(iGlobalTime*0.5),distortion_k2 = 0.5;
    vec2 dest_uv;
    
    //--------------------------Algorithm Start----------------------------------------
    //The formula is derived from this video:https://www.youtube.com/watch?v=B7qrgrrHry0&feature=youtu.be
    //and Distortion correction algorithm for Wikipedia:https://en.wikipedia.org/wiki/Distortion_(optics)#Software_correction
    rr = sqrt((source_uv.x - distortion_center.x)*(source_uv.x - distortion_center.x) + (source_uv.y - distortion_center.y)*(source_uv.y - distortion_center.y));
    r2 = rr * (1.0 + distortion_k1*(rr*rr) + distortion_k2*(rr*rr*rr*rr));
    theta = atan(source_uv.x - distortion_center.x, source_uv.y - distortion_center.y);
    distortion_x = sin(theta) * r2 * 1.0;//1.0 is  scale factor
    distortion_y = cos(theta) * r2 * 1.0;//1.0 is  scale factor
    dest_uv.x = distortion_x + 0.5;
    dest_uv.y = distortion_y + 0.5;
    //--------------------------Algorithm End------------------------------------------
    
    //Get texture from Channel0,and set dest_uv.
    fragColor = vec4( texture( iChannel0, dest_uv).r, texture( iChannel0,dest_uv).g,texture( iChannel0,dest_uv).b, 1. );
}
