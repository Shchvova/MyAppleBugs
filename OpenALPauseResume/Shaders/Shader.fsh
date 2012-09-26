//
//  Shader.fsh
//  OpenALStopStart
//
//  Created by Eric Wing on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
