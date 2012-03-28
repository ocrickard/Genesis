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

#import "GNFileRepresentation.h"
#import "GNFileManager.h"

@implementation GNFileRepresentation

@synthesize insertionIndex, insertionIndexInLine, insertionLine;

-(id)initWithRelativePath:(NSString*)path
{
    self = [super init];
    if(self)
    {
        // Set relative path
        relativePath = path;
        
        // Grab file contents with GNFileManager
        NSData* contents = [GNFileManager fileContentsAtRelativePath:relativePath];
        if(contents)
        {
            fileContents = [[NSString alloc] initWithData:contents encoding:NSUTF8StringEncoding];
        }
        else
        {
            fileContents = @"";
        }
        [self refreshLineArray];
        
        // Set insertion index and line to 0
        insertionIndex = 0;
        insertionLine = 0;
        insertionIndexInLine = 0;
        [self insertionPointChanged];
    }
    return self;
}

-(void)refreshLineArray
{
    fileLines = [NSMutableArray arrayWithArray:[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
}

-(NSUInteger)lineCount
{
    return [fileLines count];
}

-(NSString*)lineAtIndex:(NSUInteger)index
{
    return [fileLines objectAtIndex:index];
}

-(void)insertLineWithText:(NSString*)text afterLineAtIndex:(NSUInteger)index
{
    [fileLines insertObject:text atIndex:index];
}

-(void)removeLineAtIndex:(NSUInteger)index
{
    [fileLines removeObjectAtIndex:index];
}

-(void)moveLineAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    
}

-(void)setInsertionToLineAtIndex:(NSUInteger)lineIndex characterIndexInLine:(NSUInteger)characterIndex
{
    insertionIndex = 0;
    
    for(NSUInteger i = 0; i < lineIndex; i++)
    {
        insertionIndex += [[fileLines objectAtIndex:i] length];
    }
    
    insertionIndex += characterIndex;
        
    [self insertionPointChanged];
}

-(BOOL)hasText
{
    return [fileContents length] > 0;
}

-(void)insertText:(NSString*)text
{
    // Grab the text before and after the insertion point
    NSString* beforeInsertion = [fileContents substringToIndex:insertionIndex];
    NSString* afterInsertion = [fileContents substringFromIndex:insertionIndex];
    
    // Concatenate beforeInsertion + text + afterInsertion
    
    fileContents = [beforeInsertion stringByAppendingString:text];
    fileContents = [fileContents stringByAppendingString:afterInsertion];
    
    // Increment the insertion index by the length of text
    insertionIndex += [text length];
    [self insertionPointChanged];
}

-(void)deleteBackwards
{
    // Grab the text before the insertion point minus 1 and the text after insertion
    NSString* beforeInsertion = [fileContents substringToIndex:insertionIndex-1];
    NSString* afterInsertion = [fileContents substringFromIndex:insertionIndex];
    
    // Set the new file contents
    fileContents = [beforeInsertion stringByAppendingString:afterInsertion];
    
    [self refreshLineArray];
}

-(void)insertionPointChanged
{
    // Recompute insertion line and insertion index in line
    
    NSInteger charactersUntilInsertionPoint = insertionIndex;
    
    insertionLine = 0;
    insertionIndexInLine = 0;
    
    for(NSString* line in fileLines)
    {
        NSInteger difference = charactersUntilInsertionPoint - [line length];
        
        if(difference <= 0)
        {
            insertionIndexInLine = charactersUntilInsertionPoint;
            insertionIndexInLine -= (insertionLine != 0);
                        
            break;
        }
        else
        {
            charactersUntilInsertionPoint-=[line length];
        }
        
        insertionLine += 1;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kGNInsertionPointChanged"
                                                        object:self];
}

@end