/* Copyright (c) 2012, individual contributors
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#import "GNTextTableViewCell.h"

#define DEFAULT_FONT_FAMILY @"Courier"
#define DEFAULT_SIZE 16

static CTFontRef defaultFont = nil;

@implementation GNTextTableViewCell

@synthesize fileRepresentation;

-(id)initWithLine:(NSString*)lineText atIndex:(NSUInteger)index
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGNTextTableViewCellReuseIdentifier];
    if(self)
    {
        representedLineText = lineText;
        
        // Set our line ivar to nil
        line = nil;
        
        // Attributed string with representedLine's text
        attributedLine = [[NSAttributedString alloc] initWithString:representedLineText];
        
        syntaxHighlighter = [[GNSyntaxHighlighter alloc] initWithDelegate:self];
        [self addSubview:syntaxHighlighter];
        
        [syntaxHighlighter highlightText:representedLineText];
                
        // Create the default font (later should be done in preferences)
        defaultFont = CTFontCreateWithName((CFStringRef)DEFAULT_FONT_FAMILY,
                                           DEFAULT_SIZE,
                                           NULL);
        
        lineNumber = index;
    }
    
    return self;
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    staleContext = UIGraphicsGetCurrentContext();
    
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)attributedLine;
    if(line != nil)
    {
        CFRelease(line);
    }
    line = CTLineCreateWithAttributedString(attributedString);
    
    // Account for Cocoa coordinate system
    CGContextScaleCTM(staleContext, 1, -1);
    CGContextTranslateCTM(staleContext, 0, -[self frame].size.height);
    
    CGContextSetTextPosition(staleContext, 5.0, 5.0);
    CTLineDraw(line, staleContext);
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    CFIndex indexIntoString = CTLineGetStringIndexForPosition(line, touchLocation);
    
    [fileRepresentation setInsertionToLineAtIndex:lineNumber
                             characterIndexInLine:indexIntoString];
}

#pragma mark GNSyntaxHighlighterDelegate methods

-(void)didHighlightText:(NSAttributedString *)highlightedText
{
    attributedLine = highlightedText;
    [self setNeedsDisplay];
}

@end