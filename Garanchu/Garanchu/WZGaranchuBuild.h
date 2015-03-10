//
//  WZGaranchuBuild.h
//  Garanchu
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#ifndef Garanchu_WZGaranchuBuild_h
#define Garanchu_WZGaranchuBuild_h

#if !DEBUG
#define TARGET_APP_STORE 0
#endif //!DEBUG

#if DEBUG && TARGET_APP_STORE
#error must not use DEBUG to submit an app to the App Store
#endif

#endif
